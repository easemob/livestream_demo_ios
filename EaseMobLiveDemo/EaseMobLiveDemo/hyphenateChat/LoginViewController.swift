//
//  ViewController.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/5.
//

import UIKit
import EaseChatUIKit
import SwiftFFDBHotFix
import WebKit
import CryptoKit


let loginSuccessfulSwitchMainPage = "loginSuccessfulSwitchMainPage"
let backLoginPage = "backLoginPage"

final class LoginViewController: UIViewController {
    
    private let regular = "^((1[1-9][0-9])|(14[5|7])|(15([0-3]|[5-9]))|(17[013678])|(18[0,5-9]))d{8}$"
    
    private var code = ""
        
    @UserDefault("EaseChatDemoServerConfig", defaultValue: Dictionary<String,String>()) private var config
    
    @UserDefault("EaseChatDemoUserToken", defaultValue: "") private var token
    
    @UserDefault("EaseChatDemoUserPhone", defaultValue: "") private var phone
        
    private lazy var background: UIImageView = {
        UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)).contentMode(.scaleAspectFill)
    }()
    
    deinit {
        print("LoginViewController deinit")
    }
    
    private lazy var appName: UILabel = {
        UILabel(frame: CGRect(x: 30, y: 187, width: ScreenWidth - 60, height: 35)).font(UIFont(name: "PingFangSC-Medium", size: 24)).text("Login Easemob Chat".localized())
    }()
    
    lazy var sdkVersion: UILabel = {
        UILabel(frame: CGRect(x: self.view.frame.width-73.5, y: self.appName.frame.minY+8, width: 43, height: 18)).cornerRadius(Appearance.avatarRadius).font(UIFont.theme.bodyExtraSmall).textColor(UIColor.theme.neutralColor98).textAlignment(.center)
    }()
    
    private lazy var phoneNumber: UITextField = {
        UITextField(frame: CGRect(x: 30, y: self.appName.frame.maxY+22, width: ScreenWidth-60, height: 48)).delegate(self).tag(11).font(UIFont.theme.bodyLarge).placeholder("Mobile Number".localized()).leftView(UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 48)), .always).cornerRadius(Appearance.avatarRadius).clearButtonMode(.whileEditing)
    }()
    
    private lazy var pinCode: UITextField = {
        UITextField(frame: CGRect(x: 30, y: self.phoneNumber.frame.maxY+24, width: ScreenWidth-60, height: 48)).delegate(self).tag(12).font(UIFont.theme.bodyLarge).placeholder("PinCodePlaceHolder".localized()).leftView(UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 48)), .always).cornerRadius(Appearance.avatarRadius)
    }()
    
    private lazy var right: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 0, y: 0, width: 104, height: 48)).title("Get Code".localized(), .normal).addTargetFor(self, action: #selector(getPinCode), for: .touchUpInside).font(.systemFont(ofSize: 14, weight: .medium)).backgroundColor(.clear)
    }()
    
    private lazy var login: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 30, y: self.pinCode.frame.maxY+24, width: ScreenWidth - 60, height: 48)).cornerRadius(Appearance.avatarRadius).title("Login".localized(), .normal).textColor(.white, .normal).font(.systemFont(ofSize: 16, weight: .semibold)).addTargetFor(self, action: #selector(loginAction), for: .touchUpInside)
    }()
    
    private lazy var loginContainer: UIView = {
        UIView(frame: CGRect(x: 30, y: self.pinCode.frame.maxY+24, width: ScreenWidth - 60, height: 48)).backgroundColor(.white)
    }()
    
    private lazy var agree: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.login.frame.minX+5, y: self.login.frame.maxY+16, width: 20, height: 20)).image(UIImage(named: "selected"), .selected).image(UIImage(named: "unselected"), .normal).addTargetFor(self, action: #selector(agreeAction(sender:)), for: .touchUpInside)
    }()
    
    private lazy var protocolContainer: UITextView = {
        UITextView(frame: CGRect(x: self.agree.frame.maxX+4, y: self.login.frame.maxY+10, width: ScreenWidth-90-4, height: 58)).attributedText(self.protocolContent).isEditable(false).backgroundColor(.clear)
    }()
    
    public private(set) lazy var loadingView: LoadingView = {
        self.createLoading()
    }()

    // 添加 WKWebView 相关属性
    private var webViewContainer: UIView?
    private var webView: WKWebView?
    private var activityIndicator: UIActivityIndicatorView?
    
    /**
     Creates a loading view.
     
     - Returns: A `LoadingView` instance.
     */
    @objc public func createLoading() -> LoadingView {
        LoadingView(frame: self.view.bounds)
    }
    
    private var count = 60
    
    private lazy var timer: Timer? = nil
    
    private var protocolContent: NSAttributedString = NSAttributedString {
        AttributedText("Please tick to agree".localized()).font(.systemFont(ofSize: 12, weight: .regular)).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor8:UIColor.theme.neutralColor3).lineSpacing(5)
        Link("Service".localized(), url: URL(string: "https://www.easemob.com/terms/im")!).foregroundColor(Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor).font(.systemFont(ofSize: 12, weight: .medium)).underline(.single,color: Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor).lineSpacing(5)
        AttributedText(" and ".localized()).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor8:UIColor.theme.neutralColor3).font(.systemFont(ofSize: 12, weight: .regular)).foregroundColor(Color(0x3C4267)).lineSpacing(5)
        Link("Privacy Policy".localized(), url: URL(string: "https://www.easemob.com/protocol")!).foregroundColor(Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor).font(.systemFont(ofSize: 12, weight: .medium)).underline(.single,color: Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor).lineSpacing(5)
    }
    
    private lazy var serverConfig: UIButton = {
        UIButton(frame: CGRect(x: 140, y: ScreenHeight-100, width: ScreenWidth-280, height: 20)).backgroundColor(.clear).font(UIFont.theme.labelMedium).title("Server Config".localized(), .normal).addTargetFor(self, action: #selector(changeServerConfig), for: .touchUpInside)
    }()
    
    @UserDefault("EaseChatDemoServerConfig", defaultValue: Dictionary<String,String>()) private var serverInfo
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.window?.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.background,self.appName,self.sdkVersion,self.phoneNumber,self.pinCode,self.loginContainer,self.login,self.agree,self.protocolContainer,self.serverConfig,self.loadingView])
        self.loadingView.isHidden = true
        self.serverConfig.isHidden = true
        self.right.titleLabel?.textAlignment = .right
        self.sdkVersion.text = "V\(ChatUIKit_VERSION)"
        
        self.fieldSetting()
        if let debugMode = self.serverInfo["debug_mode"],debugMode == "1"{
            self.serverConfig.isHidden = false
            self.resetDisplay()
        }
        // Do any additional setup after loading the view.
        self.setContainerShadow()
        self.addGesture()
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
#if DEBUG
        self.serverConfig.isHidden = false
        self.serverInfo["debug_mode"] = "1"
        self.resetDisplay()
#endif
    }
    
    private func addGesture() {
        self.appName.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(showServerConfig))
        tap.numberOfTapsRequired = 3
        self.appName.addGestureRecognizer(tap)
    }
    
    @objc private func showServerConfig() {
        self.serverConfig.isHidden = !self.serverConfig.isHidden
        self.serverInfo["debug_mode"] = self.serverConfig.isHidden ? "0":"1"
        self.resetDisplay()
    }
    
    private func resetDisplay() {
        if let debugMode = self.serverInfo["debug_mode"],debugMode != "1" {
            self.phoneNumber.placeholder = "Mobile Number".localized()
            self.pinCode.placeholder = "PinCodePlaceHolder".localized()
            self.pinCode.keyboardType = .numberPad
            self.phoneNumber.keyboardType = .numberPad
            self.right.isHidden = false
            //此方法仅用于有限情况下内部调试，正常使用不需要
            ChatClient.shared().options.setValue(true, forKey: "enableDnsConfig")
            ChatClient.shared().changeAppkey(AppKey)
        } else {
            if let applicationKey = self.serverInfo["application"] {
                ChatClient.shared().changeAppkey(applicationKey)
            }
            if let customServer = self.serverInfo["use_custom_server"], customServer == "1" {
                ChatClient.shared().options.setValue(false, forKey: "enableDnsConfig")
                ChatClient.shared().options.setValue(true, forKey: "usingHttpsOnly")
            }
            self.right.isHidden = true
            self.phoneNumber.placeholder = "EeaseMobID".localized()
            self.pinCode.placeholder = "Password".localized()
            self.phoneNumber.keyboardType = .namePhonePad
            self.pinCode.keyboardType = .namePhonePad
        }
    }
    
    @objc private func changeServerConfig() {
        let vc = ServerConfigViewController()
        self.view.window?.backgroundColor = .black
        self.present(vc, animated: true)
    }
    
    private func fieldSetting() {
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 104, height: 48)).backgroundColor(.clear)
        rightView.addSubview(self.right)
        self.pinCode.rightView = rightView
        self.pinCode.rightViewMode = .always
        self.pinCode.keyboardType = .numberPad
        self.phoneNumber.keyboardType = .numberPad
    }
    
    private func setContainerShadow() {
        self.loginContainer.layer.cornerRadius = CGFloat(Appearance.avatarRadius.rawValue)
        self.loginContainer.layer.shadowRadius = 8
        self.loginContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.loginContainer.layer.shadowColor = UIColor(red: 0, green: 0.55, blue: 0.98, alpha: 0.2).cgColor
        self.loginContainer.layer.shadowOpacity = 1
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    @objc func timerFire() {
        DispatchQueue.main.async {
            self.count -= 1
            if self.count <= 0 {
                self.timer?.invalidate()
                self.timer = nil
                self.getAgain()
            } else { self.startCountdown() }
        }
    }
    
    private func getAgain() {
        self.right.isEnabled = true
        self.right.setTitle("Get Code".localized(), for: .normal)
        self.count = 60
    }
    
    private func startCountdown() {
        self.right.isEnabled = false
        self.right.setTitle("Get After".localized()+"(\(self.count)s)", for: .disabled)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
    }
    
    @objc private func loginAction() {
        self.view.endEditing(true)
        if self.serverConfig.isHidden {
            if self.phoneNumber.text?.count ?? 0 != 11,!(self.phoneNumber.text ?? "").chat.isMatchRegular(expression: self.regular) {
                self.showToast(toast: "PhoneError".localized())
                return
            }
            if self.pinCode.text?.count ?? 0 != 6 {
                self.showToast(toast: "PinCodeError".localized())
                return
            }
        }
        if !self.agree.isSelected {
            self.showToast(toast:"AgreeProtocol".localized())
            return
        }
        self.loginRequest()
    }
    
    @objc private func loginRequest() {
        if !self.serverConfig.isHidden {
            guard let userId = self.phoneNumber.text else {
                self.showToast(toast: "UserIdError".localized())
                return
            }
            guard let password = self.pinCode.text else {
                self.showToast(toast: "PasswordError".localized())
                return
            }
            self.loadingView.startAnimating()
            ChatClient.shared().fetchToken(withUsername: userId.lowercased(), password: password) {[weak self] token, error in
                self?.loadingView.stopAnimating()
                if error ==  nil,let chatToken = token {
                    self?.token = chatToken
                    let user = EaseChatProfile()
                    user.id = userId
                    self?.login(user: user, token: chatToken)
                    user.insert()
                } else {
                    self?.showToast(toast: "PasswordError".localized())
                }
            }
        } else {
            guard let phone = self.phoneNumber.text else {
                self.showToast(toast: "PhoneError".localized())
                return
            }
            guard let code = self.pinCode.text else {
                self.showToast(toast: "PinCodeError".localized())
                return
            }
            self.loadingView.startAnimating()
            self.phone = phone
            EasemobBusinessRequest.shared.sendPOSTRequest(api: .login(()), params: ["phoneNumber":phone,"smsCode":code]) { [weak self] result, error in
                if error == nil {
                    if let userId = result?["chatUserName"] as? String,let token = result?["token"] as? String{
                        self?.token = token
                        let user = EaseChatProfile()
                        user.id = userId
                        user.avatarURL = (result?["avatarUrl"] as? String) ?? ""
                        self?.login(user: user, token: token)
                        user.insert()
                    }
                } else {
                    self?.loadingView.stopAnimating()
                    self?.showToast(toast: "PhoneError".localized())
                }
            }
        }
    }
    
    private func login(user: ChatUserProfileProtocol,token: String) {
        if let dbPath = FMDBConnection.databasePath,dbPath.isEmpty {
            FMDBConnection.databasePath = String.documentsPath+"/EaseMobDemo/"+"\(AppKey)/"+user.id+".db"
        }
        self.loadCache()
        ChatUIKitClient.shared.login(user: user, token: token) { [weak self] error in
            self?.loadingView.stopAnimating()
            if error == nil {
                if let profiles = EaseChatProfile.select(where: "id = '\(user.id)'") as? [EaseChatProfile] {
                    if profiles.first != nil {
                        if let profile = profiles.first {
                            (user as? EaseChatProfile)?.update()
                            ChatUIKitContext.shared?.currentUser = profiles.first
                            ChatUIKitContext.shared?.userCache?[profile.id] = profile
                        }
                    }
                } else {
                    ChatUIKitContext.shared?.currentUser = user
                    ChatUIKitContext.shared?.userCache?[user.id] = user
                    let profile = EaseChatProfile()
                    profile.id = user.id
                    profile.avatarURL = user.avatarURL
                    profile.nickname = user.nickname
                    profile.insert()
                }
                self?.fillCache()
                self?.entryHome()
            } else {
                self?.showToast(toast: error?.errorDescription ?? "")
            }
        }
    }
    
    private func loadCache() {
        if let profiles = EaseChatProfile.select(where: nil) as? [EaseChatProfile] {
            for profile in profiles {
                if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(profile.id) {
                    if conversation.type == .chat {
                        ChatUIKitContext.shared?.userCache?[profile.id] = profile
                    }
                }
                if profile.id == ChatClient.shared().currentUsername ?? "" {
                    ChatUIKitContext.shared?.currentUser = profile
                    ChatUIKitContext.shared?.userCache?[profile.id] = profile
                }
            }
        }
        
    }
    
    private func fillCache() {

        if let groups = ChatClient.shared().groupManager?.getJoinedGroups() {
            var profiles = [EaseChatProfile]()
            for group in groups {
                let profile = EaseChatProfile()
                profile.id = group.groupId
                profile.nickname = group.groupName
                profile.avatarURL = group.settings.ext
                profiles.append(profile)
            }
            ChatUIKitContext.shared?.updateCaches(type: .group, profiles: profiles)
        }
        if let users = ChatUIKitContext.shared?.userCache {
            for user in users.values {
                ChatUIKitContext.shared?.userCache?[user.id]?.remark = ChatClient.shared().contactManager?.getContact(user.id)?.remark ?? ""
            }
        }
    }
    
    
    @objc private func getPinCode() {
        self.view.endEditing(true)
        if self.phoneNumber.text?.count ?? 0 != 11,!(self.phoneNumber.text ?? "").chat.isMatchRegular(expression: self.regular) {
            self.showToast(toast:"PhoneError".localized())
            return
        }
        
        guard let _ = self.phoneNumber.text else {
            self.showToast(toast: "PinCodeError".localized())
            return
        }
        showWebViewModal()
        return
    }
    
    @objc private func agreeAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc private func entryHome() {
        NotificationCenter.default.post(name: NSNotification.Name(loginSuccessfulSwitchMainPage), object: nil)
    }
    
}

extension LoginViewController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.protocolContainer.linkTextAttributes = [.foregroundColor:(style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor)]
        self.background.image = style == .dark ? UIImage(named: "login_bg_dark") : UIImage(named: "login_bg")
        self.appName.textColor = style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor
        self.sdkVersion.backgroundColor = style == .dark ? UIColor.theme.barrageDarkColor2:UIColor.theme.barrageLightColor2
        self.phoneNumber.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.pinCode.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.phoneNumber.textColor = style == .dark ? UIColor.theme.neutralColor98 : UIColor.theme.neutralColor1
        self.pinCode.textColor =  style == .dark ? UIColor.theme.neutralColor98 : UIColor.theme.neutralColor1
        self.right.setTitleColor(style == . dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor7, for: .disabled)
        self.right.setTitleColor(style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor, for: .normal)
        if style == .dark {
            self.login.setGradient([UIColor(red: 0.2, green: 0.696, blue: 1, alpha: 1),UIColor(red: 0.4, green: 0.47, blue: 1, alpha: 1)],[ CGPoint(x: 0, y: 0),CGPoint(x: 0, y: 1)])
        } else {
            self.login.setGradient([UIColor(red: 0, green: 0.62, blue: 1, alpha: 1),UIColor(red: 0.2, green: 0.293, blue: 1, alpha: 1)], [ CGPoint(x: 0, y: 0),CGPoint(x: 0, y: 1)])
        }
        self.serverConfig.setTitleColor(style == .dark ? UIColor.theme.neutralColor8:UIColor.theme.neutralColor5, for: .normal)
    }
}

// 添加 WKScriptMessageHandler 协议扩展
extension LoginViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "getVerifyResult" {
            // 处理验证结果回调
            if let resultDict = message.body as? [String: Any] {
                let code = resultDict["code"] as? Int ?? 0
                let errorInfo = resultDict["errorInfo"] as? String ?? ""
                
                // 根据验证结果进行相应处理
                if code == 200 {
                    // 验证成功，关闭模态对话框
                    dismissWebView()
                    // 这里可以添加验证成功后的业务逻辑
                     self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                         self?.timerFire()
                     }
                     self.timer?.fire()
                } else {
                    self.showToast(toast: errorInfo)
                }
            }
        }
        else if message.name == "encryptData" {
                    // 处理加密请求
                    if let dataToEncrypt = message.body as? String {
                        // 调用主应用的AES加密方法
                        let encryptedData = encryptWithAES(data: dataToEncrypt)
                        // 将加密后的数据返回给WebView
                        let jsCallback = "window.encryptCallback('\(encryptedData)');"
                        self.webView?.evaluateJavaScript(jsCallback, completionHandler: nil)
                    }
                }
    }
    
    func encryptWithAES(data: String) -> String {
        let data = Data(data.utf8)
        do {
            let encryptKey = getConfigValue(forKey: "AES_KEY") ?? ""
            let keyData = Data(base64Encoded: encryptKey)!
            let key = SymmetricKey(data: keyData)
            let sealedBox = try AES.GCM.seal(data, using: key)
            if let data = sealedBox.combined {
                // 将加密后的数据转换为Base64字符串
                return data.base64EncodedString()
            } else {
                self.showToast(toast: "Encryption failed: No combined data")
                return ""
            }
        } catch {
            self.showToast(toast: "Encryption error: \(error)")
            return ""
        }
    }
}

extension LoginViewController {
    // 显示包含 WKWebView 的模态对话框
    private func showWebViewModal() {
        // 创建容器视图
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 80))
        containerView.center = self.view.center
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowRadius = 4
        
        // 创建 WKWebView 配置
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "getVerifyResult")
        userContentController.add(self, name: "encryptData")
        configuration.userContentController = userContentController
        
        // 创建 WKWebView
        let webView = WKWebView(frame: CGRect(x: 10, y: 0, width: containerView.frame.width-20, height: containerView.frame.height), configuration: configuration)
        webView.contentMode = .scaleToFill
        webView.layer.cornerRadius = 10
        webView.navigationDelegate = self
        containerView.addSubview(webView)
        
        self.activityIndicator = UIActivityIndicatorView(style: .medium)
        webView.addSubview(self.activityIndicator!)
        self.activityIndicator?.frame = CGRect(x: webView.frame.width/2-10, y: webView.frame.height/2-10, width: 20, height: 20)
        
        // 添加半透明背景
        let backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        backgroundView.tag = 999
        
        // 添加点击背景关闭的手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundView.addGestureRecognizer(tapGesture)
        
        self.view.addSubview(backgroundView)
        self.view.addSubview(containerView)
        
        // 保存引用
        self.webViewContainer = containerView
        self.webView = webView
        let baseURL = getConfigValue(forKey: "SMS_URL") ?? ""
        if !baseURL.isEmpty,let url = URL(string: "\(baseURL)?telephone=\(self.phoneNumber.text ?? "")") {
        // 加载 index.html
            webView.load(URLRequest(url: url))
        } else {
            self.showToast(toast: "无法加载验证码页面,baseURL:\(baseURL)")
            dismissWebView()
        }
    }
    
    func getConfigValue(forKey key: String) -> String? {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path) as? [String: Any] {
            return config[key] as? String
        }
        return nil
    }
    
    
    @objc private func dismissWebView() {
        // 移除 WKWebView 的消息处理器
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "getVerifyResult")
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "encryptData")
        
        // 移除视图
        webViewContainer?.removeFromSuperview()
        webViewContainer = nil
        webView = nil
        
        // 移除半透明背景
        if let backgroundView = self.view.viewWithTag(999) {
            backgroundView.removeFromSuperview()
        }
    }
    
    @objc private func backgroundTapped() {
        dismissWebView()
    }
}

extension LoginViewController: WKNavigationDelegate {
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // 显示加载指示器或更新UI，表示开始加载
        self.activityIndicator?.startAnimating()
    }
    
    // 页面加载完成时调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 隐藏加载指示器或更新UI，表示加载完成
        self.activityIndicator?.stopAnimating()
    }
    
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // 处理加载失败的情况，例如显示错误信息或重试按钮
        self.activityIndicator?.stopAnimating()
        self.showToast(toast: "加载验证码页面失败: \(error.localizedDescription)")
    }
}


extension String {
    public func localized() -> String {
        return DemoLanguage.localValue(key: self)
    }
}

extension UIView {
    
    @discardableResult
    func setGradient(_ colors: [UIColor],_ points: [CGPoint]) -> Self {
        let gradientColors: [CGColor] = colors.map { $0.cgColor }
        let startPoint = points[0]
        let endPoint = points[1]
        let gradientLayer: CAGradientLayer = CAGradientLayer().colors(gradientColors).startPoint(startPoint).endPoint(endPoint).frame(self.bounds).backgroundColor(UIColor.clear.cgColor)
        self.layer.insertSublayer(gradientLayer, at: 0)
        return self
    }
    
}

final class EaseChatProfile:NSObject, ChatUserProfileProtocol, FFObject {
    
    static func ignoreProperties() -> [String]? {
        ["selected"]
    }
    
    static func customColumnsType() -> [String : String]? {
        nil
    }
    
    static func customColumns() -> [String : String]? {
        nil
    }
    
    static func primaryKeyColumn() -> String {
        "primaryId"
    }
    
    var primaryId: Int = 0

    var id: String = ""
    
    var remark: String = ""
    
    var selected: Bool = false
    
    var nickname: String = ""
    
    var avatarURL: String = ""
    
    public func toJsonObject() -> Dictionary<String, Any>? {
        ["ease_chat_uikit_user_info":["nickname":self.nickname,"avatarURL":self.avatarURL,"userId":self.id,"remark":""]]
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case remark
        case nickname
        case avatarURL
        case selected
    }
    
    override init() {
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        remark = try container.decode(String.self, forKey: .remark)
        nickname = try container.decode(String.self, forKey: .nickname)
        avatarURL = try container.decode(String.self, forKey: .avatarURL)
        selected = try container.decodeIfPresent(Bool.self, forKey: .selected) ?? false
    }
    
}

extension LoginViewController {
    private var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
