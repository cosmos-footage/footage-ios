//
//  RenewedPrivacyPolicyViewController.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

final class RenewedPrivacyPolicyViewController: UIViewController {
    static let legacyPolicyText = """
    1. 개인정보의 처리 목적 ‘EL.Co’ 은(는) 다음의 목적을 위하여 개인정보를 처리하고 있으며, 다음의 목적 이외의 용도로는 이용하지 않습니다.
    - 사용자가 기기 설정을 통해 위치 서비스에 관해 동의하는 한도 내에서 고객의 위치정보 수집 및 가공, 'EL.Co'는 위치정보에 대한 처리를 기기 내에서만 진행하며 외부 서버로 반출하지 않습니다.
    2. 개인정보의 처리 및 보유 기간
    ② 구체적인 개인정보 처리 및 보유 기간은 다음과 같습니다.
    ☞ 아래 예시를 참고하여 개인정보 처리업무와 개인정보 처리업무에 대한 보유기간 및 관련 법령, 근거 등을 기재합니다.
    - 전자상거래에서의 계약․청약철회, 대금결제, 재화 등 공급기록 : 5년
    3. 개인정보의 제3자 제공에 관한 사항
    ② ‘EL.Co’은(는) 개인정보를 제3자에게 제공하고 있지않습니다.
    4. 개인정보처리 위탁
    개인정보처리방침
    1. 개인정보의 처리 목적 ‘EL.Co’ 은(는) 다음의 목적을 위하여 개인정보를 처리하고 있으며, 다음의 목적 이외의 용도로는 이용하지 않습니다.
    - 사용자가 기기 설정을 통해 위치 서비스에 관해 동의하는 한도 내에서 고객의 위치정보 수집 및 가공, 'EL.Co'는 위치정보에 대한 처리를 기기 내에서만 진행하며 외부 서버로 반출하지 않습니다.
    ① ‘EL.Co’ 은(는) 정보주체로부터 개인정보를 수집할 때 동의 받은 개인정보 보유․이용기간 또는 법령에 따른 개인정보 보유․이용기간 내에서 개인정보를 처리․보유합니다.
    ① 'EL.Co’은(는) 정보주체의 동의, 법률의 특별한 규정 등 개인정보 보호법 제17조 및 제18조에 해당하는 경우에만 개인정보를 제3자에게 제공합니다.
    ① 'EL.Co'은(는) 원활한 개인정보 업무처리를 위한 개인정보처리업무의 위탁은 하고있지 않습니다.
    5. 정보주체와 법정대리인의 권리·의무 및 그 행사방법 이용자는 개인정보주체로써 다음과 같은 권리를 행사할 수 있습니다.
    1. 개인정보 열람요구
    2. 오류 등이 있을 경우 정정 요구
    3. 삭제요구
    4. 처리정지 요구
    6. 처리하는 개인정보의 항목 작성
    ① 'EL.Co'은(는) 다음의 개인정보 항목을 처리하고 있습니다.
    1
    필수항목 : 위치정보
    ② ‘EL.Co’은(는) 위탁계약 체결시 개인정보 보호법 제25조에 따라 위탁업무 수행목적 외 개인정보 처리금지, 기술적․관리적 보호조치, 재위탁 제한, 수탁자에 대한 관리․감독, 손해배상 등 책임에 관한 사항을 계약서 등 문서에 명시하고, 수탁자가 개인정보를 안전하게 처리하는지를 감독하고 있습니다.
    ① 정보주체는 이엘닷코(이하 ‘EL.Co') 에 대해 언제든지 다음 각 호의 개인정보 보호 관련 권리를 행사할 수 있습니다.
    -파기절차
    -파기기한
    8. 개인정보 자동 수집 장치의 설치•운영 및 거부에 관한 사항
    이엘닷코 은 정보주체의 이용정보를 저장하고 수시로 불러오는 ‘쿠키’를 사용하지 않습니다.
    9. 개인정보 보호책임자 작성
    ▶ 개인정보 보호책임자
    성명 : 전우태
    직책 : 공동설립자
    직급 : 대표
    연락처 : el.co.footage@gmail.com, eldotco.kr
    ※ 개인정보 보호 담당부서로 연결됩니다.
    ▶ 개인정보 보호 담당부서
    부서명 : 고객서비스부서
    담당자 : 신동녘
    연락처 : el.co.footage@gmail.com, eldotco.kr
    7. 개인정보의 파기('EL.Co') 은(는) 원칙적으로 개인정보 처리목적이 달성된 경우에는 지체없이 해당 개인정보를 파기합니다. 파기의 절차, 기한 및 방법은 다음과 같습니다.
    이용자가 입력한 정보는 목적 달성 후 별도의 내부 방침 및 기타 관련 법령에 따라 일정기간 저장된 후 혹은 즉시 파기됩니다. 개인정보는 법률에 의한 경우가 아니고서는 다른 목적으로 이용되지 않습니다.
    이용자의 개인정보는 개인정보의 보유기간이 경과된 경우에는 보유기간의 종료일로부터 5일 이내에, 개인정보의 처리 목적 달성, 해당 서비스의 폐지, 사업의 종료 등 그 개인정보가 불필요하게 되었을 때에는 개인정보의 처리가 불필요한 것으로 인정되는 날로부터 5일 이내에 그 개인정보를 파기합니다.
    ① 이엘닷코(이하 ‘EL.Co') 은(는) 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다.
    10. 개인정보 처리방침 변경
    1. 개인정보에 대한 접근 제한
    ② 정보주체께서는 이엘닷코(이하 ‘EL.Co') 의 서비스(또는 사업)을 이용하시면서 발생한 모든 개인정보 보호 관련문의, 불만처리, 피해구제 등에 관한 사항을 개인정보 보호책임자 및 담당부서로 문의하실 수 있습니다. 이엘닷코(이하 ‘EL.Co') 은(는) 정보주체의 문의에 대해 지체 없이 답변 및 처리해드릴 것입니다.
    ①이 개인정보처리방침은 시행일로부터 적용되며, 법령 및 방침에 따른 변경내용의 추가, 삭제 및 정정이 있으며 EL.Co이(가) 고객과 연락할 채널이 확보되어있는 경우에는 고객과의 채널을 통해 공지합니다.
    """

    private let policyText: () -> String
    private let titleLabel = UILabel()
    private let textView = UITextView()

    init(policyText: @escaping () -> String = { RenewedPrivacyPolicyViewController.legacyPolicyText }) {
        self.policyText = policyText
        super.init(nibName: nil, bundle: nil)
        title = "개인정보 취급방침"
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureLayout()
        render(text: policyText())
    }

    private func configureLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.text = "개인정보 취급방침"

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.textColor = .secondaryLabel
        textView.backgroundColor = .systemBackground
        textView.textContainerInset = .zero

        view.addSubview(titleLabel)
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),

            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    private func render(text: String) {
        textView.text = text
    }
}
