//
//  PhotoManager.swift
//  footage
//
//  Created by Wootae on 7/6/20.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import Foundation
import RealmSwift
import Photos
import MapKit

class JourneyManager {
    // shared variables among JourneyVC, PhotoCollection, PhotoSelection
    weak var journeyVC: JourneyViewController?
    var journeyIndex = 0
    var photoVC: PhotoCollectionVC! = nil
    let cacheManager = PHCachingImageManager()
    private let mediaRepository: MediaRepository
    
    var journey: Journey! = nil
    var assets: [[Asset]] = [[]] // first array should remain empty - corresponds to firstcell
    var bookmark: [Int] = [0] // index: section / value: footstepNumber
    var annotations: [FootAnnotation] = []
    var groupImages: [UIView] = [UIView()] // first cell = empty view
    var randomDegree: CGFloat {
        get { return CGFloat.random(in: -0.3...0.3) }
    }
    
    var sliderIsMoving = false
    var expandedSection = -1
    var removeActivated = false
    var selectedPin: MKAnnotationView? {
        didSet {
            if let oldValue = oldValue { // unselect previously selcted pin
                if oldValue.isSelected {
                    oldValue.isSelected = false
                }
            }
        }
    }
    var currentIndexPath: IndexPath = IndexPath(item: 0, section: 0) {
        didSet {
            if currentIndexPath.section != 0 { // scrolled to one of the footsteps
                journeyVC?.addButton.alpha = 0.5
                journeyVC?.addButton.isUserInteractionEnabled = false
                journeyVC?.footstepLabel.alpha = 1
            }
            if oldValue.section != currentIndexPath.section {
                let newFootstepNumber = bookmark[currentIndexPath.section]
                journeyVC?.footstepLabel.text = "# " + String(newFootstepNumber)
                journeyVC?.slider.value = Float(newFootstepNumber)
                DrawOnMap.moveCenterTo(journey.footsteps[newFootstepNumber].coordinate, on: (journeyVC?.mainMap)!, centerMark: journeyVC?.centerMark)
            }
        }
    }
    
    init(journeyIndex: Int, mediaRepository: MediaRepository = RealmMediaRepository()) {
        self.journeyIndex = journeyIndex
        self.mediaRepository = mediaRepository
        self.journey = DateViewController.journeys[journeyIndex]
        loadAssets(footsteps: self.journey.footsteps)
    }
    
    func footstepNumber(for section: Int) -> Int {
        return bookmark[section]
    }
    
    func section(for footstepNumber: Int) -> Int {
        return bookmark.lastIndex(of: footstepNumber) ?? 0
    }
    
    func moveSliderTo(value: Int) {
        DrawOnMap.moveCenterTo(journey.footsteps[value].coordinate, on: (journeyVC?.mainMap)!, centerMark: journeyVC?.centerMark)
        journeyVC?.slider.value = Float(value)
    }
    
    func loadAssets(footsteps: List<Footstep>) { // TODO: ASYNC?
        for footstepNumber in 0..<footsteps.count {
            let footstep = footsteps[footstepNumber]
            if footstep.notes.isEmpty { continue }
            else {
                var assetGroup: [Asset] = []
                for assetNumber in 0..<footstep.notes.count { // TODO: change to map
                    let asset = Asset(photo: footstep.photos[assetNumber], note: footstep.notes[assetNumber], footstepNumber: footstepNumber)
                    assetGroup.append(asset)
                }
                assets.append(assetGroup)
                bookmark.append(footstepNumber)
                groupImages.append(loadGroupImage(for: footstepNumber))
            }
        }
    }
    
    func loadGroupImage(for footstepNumber: Int) -> UIView { // TODO: ASYNC?
        let view = UIView(frame: CGRect(x: 0, y: 0, width: PhotoCollectionLayout.groupWidth, height: PhotoCollectionLayout.cellHeight))
        view.isUserInteractionEnabled = false
        let imageWidth = PhotoCollectionLayout.groupWidth // okay to extend over - section inset
        let imageHeight = PhotoCollectionLayout.cellHeight * 0.7
        let defaultImage = UIImageView(frame: CGRect(x: 0, y: (view.frame.height - imageHeight) / 2,
        width: imageWidth, height: imageHeight))
        if journey.footsteps[footstepNumber].photos.isEmpty {
            view.isUserInteractionEnabled = true
            defaultImage.image = #imageLiteral(resourceName: "emptyPhotoBox")
            defaultImage.contentMode = .scaleAspectFill
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToSelection)))
            view.addSubview(defaultImage)
        }
        for photoData in journey.footsteps[footstepNumber].photos {
            let imageView = UIImageView(frame: CGRect(x: 0, y: (view.frame.height - imageHeight) / 2,
                                                      width: imageWidth, height: imageHeight))
            imageView.contentMode = .scaleAspectFit
            imageView.image = downsample(imageData: photoData, to: imageView.frame.size, scale: UIScreen.main.scale)
            imageView.transform = imageView.transform.rotated(by: randomDegree)
            imageView.isUserInteractionEnabled = false // for tap recognizer
            view.addSubview(imageView)
            view.sendSubviewToBack(imageView)
        }
        
        return view
    }
    
    @objc func goToSelection() {
        journeyVC?.performSegue(withIdentifier: "goToPhotoSelection", sender: journeyVC)
    }
    
    func loadAnnotations() -> [FootAnnotation] {
        let footsteps = journey.footsteps
        for footstepNumber in 0..<footsteps.count {
            let footstep = footsteps[footstepNumber]
            if !footstep.photos.isEmpty {
                annotations.append(FootAnnotation(footstep: footstep, number: footstepNumber))
            }
        }
        return annotations
    }
    
    func saveNewPhotos(pHAssets: [PHAsset], footstepNumber: Int) {
        let section = currentIndexPath.section
        let footstep = journey.footsteps[footstepNumber]
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        var assetsToAdd: [Asset] = []
        let dispatchGroup = DispatchGroup()
        for phAsset in pHAssets {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                self.cacheManager.requestImageDataAndOrientation(for: phAsset, options: options) { (imageData, dataUTI, orientation, info) in
                    let imageData = imageData ?? Data()
                    DispatchQueue.main.async {
                        do {
                            try self.mediaRepository.appendPhoto(imageData, to: footstep)
                        } catch { print(error) }
                        assetsToAdd.append(Asset(photo: imageData, note: "", footstepNumber: footstepNumber))
                        dispatchGroup.leave()
                    }
                }
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.global()) {
            DispatchQueue.main.async {
                self.assets[section].append(contentsOf: assetsToAdd)
                self.groupImages[section] = self.loadGroupImage(for: self.footstepNumber(for: section))
                self.photoVC.collectionView.reloadSections(IndexSet(integer: section))
                self.photoVC.collectionView.scrollToItem(at: self.currentIndexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    func saveNewNote(content: String, section: Int, item: Int) {
        assets[section][item].note = content
        let footstep = journey.footsteps[bookmark[section]]
        do { try mediaRepository.replaceNote(content, at: item, in: footstep) } catch { print(error) }
    }
    
    func removeAsset(section: Int, item: Int) { // TODO: 마지막까지 지웠을때 다시 defualt 이미지 띄우기
        if item == assets[section].count { // delete?
            currentIndexPath = IndexPath(item: item - 1, section: section)
        }
        for index in (item + 1)..<assets[section].count {
            if let cell = photoVC.collectionView.cellForItem(at: IndexPath(item: index, section: section)) as? CardCell { cell.item -= 1 }
        }
        assets[section].remove(at: item)
        groupImages[section] = loadGroupImage(for: footstepNumber(for: section))
        let footstep = journey.footsteps[footstepNumber(for: section)]
        do { try mediaRepository.removeAsset(at: item, from: footstep) } catch { print(error) }
        if assets[section].isEmpty {
            removeSection(section: section)
        } else { photoVC.collectionView.deleteItems(at: [IndexPath(item: item, section: section)]) }
    }
    
    func removeSection(section: Int) {
        for index in (section + 1)..<assets.count {
            if let cell = photoVC.collectionView.cellForItem(at: IndexPath(item: 0, section: index)) as? GroupCell { cell.section -= 1 }
        }
        let footstep = journey.footsteps[footstepNumber(for: section)]
        do { try mediaRepository.removeAllAssets(from: footstep) } catch { print(error) }
        assets.remove(at: section)
        bookmark.remove(at: section)
        groupImages.remove(at: section)
        journeyVC?.mainMap.removeAnnotation(annotations[section - 1])
        annotations.remove(at: section - 1)
        photoVC.collectionView.reloadData()
    }
    
    func prepareNewFootstep(footstepNumber: Int, annotation: FootAnnotation) {
        bookmark.append(footstepNumber)
        bookmark.sort()
        let newSection = bookmark.lastIndex(of: footstepNumber)!
        assets.insert([], at: newSection)
        groupImages.insert(loadGroupImage(for: footstepNumber), at: newSection)
        annotations.insert(annotation, at: newSection - 1)
        photoVC.collectionView.insertSections(IndexSet(integer: newSection))
        photoVC.collectionView.scrollToItem(at: IndexPath(item: 0, section: newSection), at: .centeredHorizontally, animated: true)
        currentIndexPath = IndexPath(item: 0, section: newSection)
    }
    
    func downsample(imageData: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions)!
        
        let maxDimentionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampledOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                  kCGImageSourceShouldCacheImmediately: true,
                                  kCGImageSourceCreateThumbnailWithTransform: true,
                                  kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels] as CFDictionary
        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions)!
        return UIImage(cgImage: downsampledImage)
    }
    
    
}
