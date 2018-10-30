//
//  ZKCarousel.swift
//  Delego
//
//  Created by Zachary Khan on 6/8/17.
//  Copyright © 2017 ZacharyKhan. All rights reserved.
//

import UIKit

final public class ZKCarousel: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {


    public var slides : [ZKCarouselSlide] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    private lazy var tapGesture : UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(tap:)))
        return tap
    }()

    public lazy var pageControl : UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 3
        control.currentPage = 0
        control.hidesForSinglePage = true
        control.pageIndicatorTintColor = .lightGray
        control.currentPageIndicatorTintColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    fileprivate lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.isPagingEnabled = true
        cv.register(carouselCollectionViewCell.self, forCellWithReuseIdentifier: "slideCell")
        cv.clipsToBounds = true
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.bounces = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupCarousel()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCarousel()
    }

    private func setupCarousel() {
        self.backgroundColor = .clear

        self.addSubview(collectionView)
        NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: collectionView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: collectionView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0).isActive = true

        self.collectionView.addGestureRecognizer(self.tapGesture)

        self.addSubview(pageControl)
        NSLayoutConstraint(item: pageControl, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 20).isActive = true
        NSLayoutConstraint(item: pageControl, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -20).isActive = true
        NSLayoutConstraint(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -5).isActive = true
        NSLayoutConstraint(item: pageControl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25).isActive = true
        self.bringSubview(toFront: pageControl)
    }

    @objc private func tapGestureHandler(tap: UITapGestureRecognizer?) {
        print("tapped")
    }

    @objc private func autoSlideHandler(tap: UITapGestureRecognizer?) {
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath: IndexPath = collectionView.indexPathForItem(at: visiblePoint) ?? IndexPath(item: 0, section: 0)
        let index = visibleIndexPath.item

        if index == (slides.count-1) {
            let indexPathToShow = IndexPath(item: 0, section: 0)
            self.collectionView.selectItem(at: indexPathToShow, animated: true, scrollPosition: .centeredHorizontally)
        } else {
            let indexPathToShow = IndexPath(item: (index + 1), section: 0)
            self.collectionView.selectItem(at: indexPathToShow, animated: true, scrollPosition: .centeredHorizontally)
        }
    }

    private var timer : Timer = Timer()
    public var interval : Double?

    public func start() {
        timer = Timer.scheduledTimer(timeInterval: interval ?? 1.0, target: self, selector: #selector(autoSlideHandler(tap:)), userInfo: nil, repeats: true)
        timer.fire()
    }

    public func stop() {
        timer.invalidate()
    }

    public func selectedIndexPath() -> IndexPath? {
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        return collectionView.indexPathForItem(at: visiblePoint)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "slideCell", for: indexPath) as! carouselCollectionViewCell
        cell.slide = self.slides[indexPath.item]
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "slideCell", for: indexPath) as! carouselCollectionViewCell
        let _url = cell.pageUrl!
        if let topController = UIApplication.topViewController() {
            topController.present(WebViewController.init(url: _url, title: "トピック", pointToken: ""), animated: true, completion: nil)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(slides.count)
        return self.slides.count
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        return size
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }

}

fileprivate class carouselCollectionViewCell: UICollectionViewCell {

    fileprivate var slide : ZKCarouselSlide? {
        didSet {
            guard let slide = slide else {
                print("ZKCarousel could not parse the slide you provided. \n\(String(describing: self.slide))")
                return
            }
            self.parseData(forSlide: slide)
        }
    }

    private lazy var imageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .clear
        iv.clipsToBounds = true
        iv.addBlackGradientLayer(frame: self.bounds)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private var titleLabel : UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var descriptionLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var pageUrl : URL?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        self.backgroundColor = .clear
        self.clipsToBounds = true

        self.addSubview(self.imageView)
        NSLayoutConstraint(item: self.imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self.imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self.imageView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self.imageView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0).isActive = true

        self.addSubview(self.descriptionLabel)
        let left = NSLayoutConstraint(item: descriptionLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 15)
        let right = NSLayoutConstraint(item: descriptionLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -15)
        let bottom = NSLayoutConstraint(item: descriptionLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.9, constant: 0)
        let top = NSLayoutConstraint(item: descriptionLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.25, constant: 0)
        NSLayoutConstraint.activate([left, right, bottom, top])

        self.addSubview(self.titleLabel)
        NSLayoutConstraint(item: self.titleLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 15).isActive = true
        NSLayoutConstraint(item: self.titleLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -15).isActive = true
        NSLayoutConstraint(item: self.titleLabel, attribute: .bottom, relatedBy: .equal, toItem: self.descriptionLabel, attribute: .top, multiplier: 1.0, constant: 8).isActive = true
        NSLayoutConstraint(item: self.titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 43).isActive = true
    }

    private func parseData(forSlide slide: ZKCarouselSlide) {
        if let image = slide.slideImage {
            self.imageView.image = image
        }

        if let title = slide.slideTitle {
            self.titleLabel.text = title
        }

        if let description = slide.slideDescription {
            self.descriptionLabel.text = description
        }

        if let url = slide.slideURL {
            self.pageUrl = url
        }

        return
    }

}

final public class ZKCarouselSlide : NSObject {

    public var slideImage : UIImage?
    public var slideTitle : String?
    public var slideDescription: String?
    public var slideURL: URL?

    public init(image: UIImage, title: String, description: String, URL: URL) {
        slideImage = image
        slideTitle = title
        slideDescription = description
        slideURL = URL
    }

    override init() {
        super.init()
    }

}

extension UIView {

    func addConstraintsWithFormat(_ format: String, views: UIView...) {

        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }


}

extension UIImageView {
    func addBlackGradientLayer(frame: CGRect){
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.6).cgColor]
        gradient.locations = [0.0, 0.6]
        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

import UIKit
import WebKit

class WebViewController: UIViewController, UINavigationControllerDelegate, WKUIDelegate, WKNavigationDelegate {

    var url: URL!
    var webView: WKWebView!
    var titleName: String!
    var pointToken: String!
    var backBarButton: UIBarButtonItem?
    var forwardBarButton: UIBarButtonItem?


    init(url: URL, title: String, pointToken: String) {
        self.url = url
        self.titleName = title
        self.pointToken = pointToken
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.prepareNavigationBar()
        var request = URLRequest(url: url!)
        //        request.httpShouldHandleCookies = false
        //        request.setValue("document.cookie = 'token=\(pointToken)';", forHTTPHeaderField: "Cookie")
        //        webView.load(request)

        let statusBarHeight: CGFloat! = UIApplication.shared.statusBarFrame.height
        let width: CGFloat! = self.view.bounds.width
        let height: CGFloat! = self.view.bounds.height
        let userContentController = WKUserContentController()
        let cookieScript = WKUserScript(source: "document.cookie = 'token=\(pointToken!)';", injectionTime: .atDocumentStart, forMainFrameOnly: true)
        userContentController.addUserScript(cookieScript)
        let wkWebViewConfig = WKWebViewConfiguration()
        wkWebViewConfig.userContentController = userContentController

        self.webView = WKWebView(frame: CGRect(x:0, y:statusBarHeight + (self.navigationController?.navigationBar.frame.size.height)!, width:width, height:height - statusBarHeight - (self.tabBarController?.tabBar.frame.size.height)! - (self.navigationController?.navigationBar.frame.size.height)!), configuration: wkWebViewConfig)
        self.webView.navigationDelegate = self
        self.view.addSubview(self.webView)

        request.httpShouldHandleCookies = false
        request.setValue("document.cookie = 'token=\(pointToken!)';",forHTTPHeaderField: "Cookie")

        // 初回リクエスト
        // WebViewが表示された後は、基本的にはこのload.Request()は呼び出されない
        self.webView.load(request)

        navigationController?.delegate = self
        webView.navigationDelegate = self
        if #available(iOS 11.0, *) {
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies {
                print($0)
            }
        } else {
            // Fallback on earlier versions
        }
    }



    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("遷移開始")
        if #available(iOS 11.0, *) {
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies {
                print($0)
            }
        } else {
            // Fallback on earlier versions
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }




    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if url.absoluteString.range(of: "//itunes.apple.com/") != nil {
            if #available(iOS 10.0, *) {
                if UIApplication.shared.responds(to: #selector(UIApplication.open(_:options:completionHandler:))) {
                    UIApplication.shared.open(url, options: [UIApplicationOpenURLOptionUniversalLinksOnly:false], completionHandler: { (finished: Bool) in
                    })
                }
                else {
                    // iOS 10 で deprecated 必要なら以降のopenURLも振り分ける
                    // iOS 10以降は UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    UIApplication.shared.openURL(url)
                }
            } else {
                // Fallback on earlier versions
            }
            decisionHandler(.cancel)
            return
        }
        else if !url.absoluteString.hasPrefix("http://")
            && !url.absoluteString.hasPrefix("https://") {
            // URL Schemeをinfo.plistで公開しているアプリか確認
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
                decisionHandler(.cancel)
                return
            }
            //                // 確認せずとりあえず開く
            //                UIApplication.shared.openURL(url)
            //                decisionHandler(.cancel)
            //                return
        }

        switch navigationAction.navigationType {
        case .linkActivated:
            if navigationAction.targetFrame == nil
                || !navigationAction.targetFrame!.isMainFrame  {
                // <a href="..." target="_blank"> が押されたとき
                webView.load(URLRequest(url: url))
                decisionHandler(.cancel)
                return
            }
        case .backForward:
            break
        case .formResubmitted:
            break
        case .formSubmitted:
            if navigationAction.targetFrame == nil
                || !navigationAction.targetFrame!.isMainFrame  {
                // <a href="..." target="_blank"> が押されたとき
                webView.load(URLRequest(url: url))
                decisionHandler(.cancel)
                return
            }
        case .other:
            break
        case .reload:
            break
        } // 全要素列挙した場合はdefault不要 (足りない要素が追加されたときにエラーを吐かせる目的)

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.canGoBack {
            let backStyle = BarButtonIconStyle(icon: .chevron_left, color: .black)
            backBarButton = UIBarButtonItem.icon(with: backStyle, target: self, action: #selector(onClickBackBarButton))
            backBarButton?.isEnabled = true
        } else {
            let backStyle = BarButtonIconStyle(icon: .chevron_left, color: .lightGray)
            backBarButton = UIBarButtonItem.icon(with: backStyle, target: self, action: #selector(onClickBackBarButton))
            backBarButton?.isEnabled = false
        }
        if webView.canGoForward {
            let forwardStyle = BarButtonIconStyle(icon: .chevron_right, color: .black)
            forwardBarButton = UIBarButtonItem.icon(with: forwardStyle, target: self, action: #selector(onClickForwardBarButton))
            forwardBarButton?.isEnabled = true
        } else {
            let forwardStyle = BarButtonIconStyle(icon: .chevron_right, color: .lightGray)
            forwardBarButton = UIBarButtonItem.icon(with: forwardStyle, target: self, action: #selector(onClickForwardBarButton))
            forwardBarButton?.isEnabled = false
        }

        let fixedItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedItem.width = 20
        self.navigationItem.leftBarButtonItems = [backBarButton!, fixedItem ,forwardBarButton!]
    }
}



private extension WebViewController {
    func prepareNavigationBar() {
        self.navigationItem.title = titleName

        let closeStyle = BarButtonIconStyle(icon: .close, color: .black)
        let closeButton = UIBarButtonItem.icon(with: closeStyle, target: self, action: #selector(didTapCloseButton))
        self.navigationItem.rightBarButtonItem = closeButton

        let backStyle = BarButtonIconStyle(icon: .chevron_left, color: .lightGray)
        backBarButton = UIBarButtonItem.icon(with: backStyle, target: self, action: #selector(onClickBackBarButton))
        backBarButton?.isEnabled = false

        let forwardStyle = BarButtonIconStyle(icon: .chevron_right, color: .lightGray)
        forwardBarButton = UIBarButtonItem.icon(with: forwardStyle, target: self, action: #selector(onClickForwardBarButton))
        forwardBarButton?.isEnabled = false

        let fixedItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedItem.width = 20
        self.navigationItem.leftBarButtonItems = [backBarButton!, fixedItem ,forwardBarButton!]
    }

    @objc func didTapCloseButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func onClickBackBarButton(sender: UIButton){
        // 前のページ
        self.webView.goBack()
    }
    @objc func onClickForwardBarButton(sender: UIButton){
        // 次のページ
        self.webView.goForward()
    }
}


struct BarButtonIconStyle {

    var icon: FontIcon
    var color: UIColor = .lightGray

    init(icon: FontIcon) {
        self.icon = icon
    }

    init(icon: FontIcon, color: UIColor) {
        self.icon = icon
        self.color = color
    }
}

struct BarButtonTextStyle {

    var text: String
    var color: UIColor

    init(text: String, color: UIColor) {
        self.text = text
        self.color = color
    }
}

extension UIBarButtonItem {

    static func icon(with style: BarButtonIconStyle, target: Any?, action: Selector) -> UIBarButtonItem {
        let attributes = [NSAttributedStringKey.font: UIFont.icon(size: 32)]
        let button = UIBarButtonItem(title: style.icon.value, style: .plain, target: target, action: action)
        button.setTitleTextAttributes(attributes, for: .normal)
        button.setTitleTextAttributes(attributes, for: .highlighted)
        button.setTitleTextAttributes(attributes, for: .selected)
        button.setTitleTextAttributes(attributes, for: .disabled)
        button.tintColor = style.color
        return button
    }

    static func text(with style: BarButtonTextStyle, target: Any?, action: Selector) -> UIBarButtonItem {
        let attributes = [NSAttributedStringKey.font: UIFont.semiBold(type: .m)]
        let button = UIBarButtonItem(title: style.text, style: .plain, target: target, action: action)
        button.setTitleTextAttributes(attributes, for: .normal)
        button.setTitleTextAttributes(attributes, for: .highlighted)
        button.setTitleTextAttributes(attributes, for: .selected)
        button.setTitleTextAttributes(attributes, for: .disabled)
        button.tintColor = style.color
        return button
    }
}

//
//  FontIcon.swift
//  gexOfficial
//
//  Created by kodai ozawa on 2017/11/09.
//  Copyright © 2017 conol. All rights reserved.
//

import UIKit

enum FontIcon: Int, CatalogueType {
    case airplane_off
    case airplane
    case album
    case archive
    case assignment_account
    case assignment_alert
    case assignment_check
    case assignment_o
    case assignment_return
    case assignment_returned
    case assignment
    case attachment_alt
    case attachment
    case audio
    case badge_check
    case balance_wallet
    case balance
    case battery_alert
    case battery_flash
    case battery_unknown
    case battery
    case bike
    case block_alt
    case block
    case boat
    case book_image
    case book
    case bookmark_outline
    case bookmark
    case brush
    case bug
    case bus
    case cake
    case car_taxi
    case car_wash
    case car
    case card_giftcard
    case card_membership
    case card_travel
    case card
    case case_check
    case case_download
    case case_play
    case cast_connected
    case cast
    case chart_donut
    case chart
    case city_alt
    case city
    case close_circle_o
    case close_circle
    case close
    case cocktail
    case code_setting
    case code_smartphone
    case code
    case coffee
    case collection_bookmark
    case collection_case_play
    case collection_folder_image
    case collection_image_o
    case collection_image
    case collection_item_1
    case collection_item_2
    case collection_item_3
    case collection_item_4
    case collection_item_5
    case collection_item_6
    case collection_item_7
    case collection_item_8
    case collection_item_9_plus
    case collection_item_9
    case collection_item
    case collection_music
    case collection_pdf
    case collection_plus
    case collection_speaker
    case collection_text
    case collection_video
    case compass
    case cutlery
    case delete
    case dialpad
    case dns
    case drink
    case edit
    case email_open
    case email
    case eye_off
    case eye
    case eyedropper
    case favorite_outline
    case favorite
    case filter_list
    case fire
    case flag
    case flare
    case flash_auto
    case flash_off
    case flash
    case flip
    case flower_alt
    case flower
    case font
    case fullscreen_alt
    case fullscreen_exit
    case fullscreen
    case functions
    case gas_station
    case gesture
    case globe_alt
    case globe_lock
    case globe
    case graduation_cap
    case home
    case hospital_alt
    case hospital
    case hotel
    case hourglass_alt
    case hourglass_outline
    case hourglass
    case http
    case image_alt
    case image_o
    case image
    case inbox
    case invert_colors_off
    case invert_colors
    case key
    case label_alt_outline
    case label_alt
    case label_heart
    case label
    case labels
    case lamp
    case landscape
    case layers_off
    case layers
    case library
    case link
    case lock_open
    case lock_outline
    case lock
    case mail_reply_all
    case mail_reply
    case mail_send
    case mall
    case map
    case menu
    case money_box
    case money_off
    case money
    case more_vert
    case more
    case movie_alt
    case movie
    case nature_people
    case nature
    case navigation
    case open_in_browser
    case open_in_new
    case palette
    case parking
    case pin_account
    case pin_assistant
    case pin_drop
    case pin_help
    case pin_off
    case pin
    case pizza
    case plaster
    case power_setting
    case power
    case print
    case puzzle_piece
    case quote
    case railway
    case receipt
    case refresh_alt
    case refresh_sync_alert
    case refresh_sync_off
    case refresh_sync
    case refresh
    case roller
    case ruler
    case scissors
    case screen_rotation_lock
    case screen_rotation
    case search_for
    case search_in_file
    case search_in_page
    case search_replace
    case search
    case seat
    case settings_square
    case settings
    case shield_check
    case shield_security
    case shopping_basket
    case shopping_cart_plus
    case shopping_cart
    case sign_in
    case sort_amount_asc
    case sort_amount_desc
    case sort_asc
    case sort_desc
    case spellcheck
    case storage
    case store_24
    case store
    case subway
    case sun
    case tab_unselected
    case tab
    case tag_close
    case tag_more
    case tag
    case thumb_down
    case thumb_up_down
    case thumb_up
    case ticket_star
    case toll
    case toys
    case traffic
    case translate
    case triangle_down
    case triangle_up
    case truck
    case turning_sign
    case wallpaper
    case washing_machine
    case window_maximize
    case window_minimize
    case window_restore
    case wrench
    case zoom_in
    case zoom_out
    case alert_circle_o
    case alert_circle
    case alert_octagon
    case alert_polygon
    case alert_triangle
    case help_outline
    case help
    case info_outline
    case info
    case notifications_active
    case notifications_add
    case notifications_none
    case notifications_off
    case notifications_paused
    case notifications
    case account_add
    case account_box_mail
    case account_box_o
    case account_box_phone
    case account_box
    case account_calendar
    case account_circle
    case account_o
    case account
    case accounts_add
    case accounts_alt
    case accounts_list_alt
    case accounts_list
    case accounts_outline
    case accounts
    case face
    case female
    case male_alt
    case male_female
    case male
    case mood_bad
    case mood
    case run
    case walk
    case cloud_box
    case cloud_circle
    case cloud_done
    case cloud_download
    case cloud_off
    case cloud_outline_alt
    case cloud_outline
    case cloud_upload
    case cloud
    case download
    case file_plus
    case file_text
    case file
    case folder_outline
    case folder_person
    case folder_star_alt
    case folder_star
    case folder
    case gif
    case upload
    case border_all
    case border_bottom
    case border_clear
    case border_color
    case border_horizontal
    case border_inner
    case border_left
    case border_outer
    case border_right
    case border_style
    case border_top
    case border_vertical
    case copy
    case crop
    case format_align_center
    case format_align_justify
    case format_align_left
    case format_align_right
    case format_bold
    case format_clear_all
    case format_clear
    case format_color_fill
    case format_color_reset
    case format_color_text
    case format_indent_decrease
    case format_indent_increase
    case format_italic
    case format_line_spacing
    case format_list_bulleted
    case format_list_numbered
    case format_ltr
    case format_rtl
    case format_size
    case format_strikethrough_s
    case format_strikethrough
    case format_subject
    case format_underlined
    case format_valign_bottom
    case format_valign_center
    case format_valign_top
    case redo
    case select_all
    case space_bar
    case text_format
    case transform
    case undo
    case wrap_text
    case comment_alert
    case comment_alt_text
    case comment_alt
    case comment_edit
    case comment_image
    case comment_list
    case comment_more
    case comment_outline
    case comment_text_alt
    case comment_text
    case comment_video
    case comment
    case comments
    case check_all
    case check_circle_u
    case check_circle
    case check_square
    case check
    case circle_o
    case circle
    case dot_circle_alt
    case dot_circle
    case minus_circle_outline
    case minus_circle
    case minus_square
    case minus
    case plus_circle_o_duplicate
    case plus_circle_o
    case plus_circle
    case plus_square
    case plus
    case square_o
    case star_circle
    case star_half
    case star_outline
    case star
    case bluetooth_connected
    case bluetooth_off
    case bluetooth_search
    case bluetooth_setting
    case bluetooth
    case camera_add
    case camera_alt
    case camera_bw
    case camera_front
    case camera_mic
    case camera_party_mode
    case camera_rear
    case camera_roll
    case camera_switch
    case camera
    case card_alert
    case card_off
    case card_sd
    case card_sim
    case desktop_mac
    case desktop_windows
    case device_hub
    case devices_off
    case devices
    case dock
    case floppy
    case gamepad
    case gps_dot
    case gps_off
    case gps
    case headset_mic
    case headset
    case input_antenna
    case input_composite
    case input_hdmi
    case input_power
    case input_svideo
    case keyboard_hide
    case keyboard
    case laptop_chromebook
    case laptop_mac
    case laptop
    case mic_off
    case mic_outline
    case mic_setting
    case mic
    case mouse
    case network_alert
    case network_locked
    case network_off
    case network_outline
    case network_setting
    case network
    case phone_bluetooth
    case phone_end
    case phone_forwarded
    case phone_in_talk
    case phone_locked
    case phone_missed
    case phone_msg
    case phone_paused
    case phone_ring
    case phone_setting
    case phone_sip
    case phone
    case portable_wifi_changes
    case portable_wifi_off
    case portable_wifi
    case radio
    case reader
    case remote_control_alt
    case remote_control
    case router
    case scanner
    case smartphone_android
    case smartphone_download
    case smartphone_erase
    case smartphone_info
    case smartphone_iphone
    case smartphone_landscape_lock
    case smartphone_landscape
    case smartphone_lock
    case smartphone_portrait_lock
    case smartphone_ring
    case smartphone_setting
    case smartphone_setup
    case smartphone
    case speaker
    case tablet_android
    case tablet_mac
    case tablet
    case tv_alt_play
    case tv_list
    case tv_play
    case tv
    case usb
    case videocam_off
    case videocam_switch
    case videocam
    case watch
    case wifi_alt_2
    case wifi_alt
    case wifi_info
    case wifi_lock
    case wifi_off
    case wifi_outline
    case wifi
    case arrow_left_bottom
    case arrow_left
    case arrow_merge
    case arrow_missed
    case arrow_right_top
    case arrow_right
    case arrow_split
    case arrows
    case caret_down_circle
    case caret_down
    case caret_left_circle
    case caret_left
    case caret_right_circle
    case caret_right
    case caret_up_circle
    case caret_up
    case chevron_down
    case chevron_left
    case chevron_right
    case chevron_up
    case forward
    case long_arrow_down
    case long_arrow_left
    case long_arrow_return
    case long_arrow_right
    case long_arrow_tab
    case long_arrow_up
    case rotate_ccw
    case rotate_cw
    case rotate_left
    case rotate_right
    case square_down
    case square_right
    case swap_alt
    case swap_vertical_circle
    case swap_vertical
    case swap
    case trending_down
    case trending_flat
    case trending_up
    case unfold_less
    case unfold_more
    case apps
    case grid_off
    case grid
    case view_agenda
    case view_array
    case view_carousel
    case view_column
    case view_comfy
    case view_compact
    case view_dashboard
    case view_day
    case view_headline
    case view_list_alt
    case view_list
    case view_module
    case view_quilt
    case view_stream
    case view_subtitles
    case view_toc
    case view_web
    case view_week
    case widgets
    case alarm_check
    case alarm_off
    case alarm_plus
    case alarm_snooze
    case alarm
    case calendar_alt
    case calendar_check
    case calendar_close
    case calendar_note
    case calendar
    case time_countdown
    case time_interval
    case time_restore_setting
    case time_restore
    case time
    case timer_off
    case timer
    case android_alt
    case android
    case apple
    case behance
    case codepen
    case dribbble
    case dropbox
    case evernote
    case facebook_box
    case facebook
    case github_box
    case github
    case google_drive
    case google_earth
    case google_glass
    case google_maps
    case google_pages
    case google_play
    case google_plus_box
    case google_plus
    case google
    case instagram
    case language_css3
    case language_html5
    case language_javascript
    case language_python_alt
    case language_python
    case lastfm
    case linkedin_box
    case paypal
    case pinterest_box
    case pocket
    case polymer
    case share
    case stackoverflow
    case steam_square
    case steam
    case twitter_box
    case twitter
    case vk
    case wikipedia
    case windows
    case aspect_ratio_alt
    case aspect_ratio
    case blur_circular
    case blur_linear
    case blur_off
    case blur
    case brightness_2
    case brightness_3
    case brightness_4
    case brightness_5
    case brightness_6
    case brightness_7
    case brightness_auto
    case brightness_setting
    case broken_image
    case center_focus_strong
    case center_focus_weak
    case compare
    case crop_16_9
    case crop_3_2
    case crop_5_4
    case crop_7_5
    case crop_din
    case crop_free
    case crop_landscape
    case crop_portrait
    case crop_square
    case exposure_alt
    case exposure
    case filter_b_and_w
    case filter_center_focus
    case filter_frames
    case filter_tilt_shift
    case gradient
    case grain
    case graphic_eq
    case hdr_off
    case hdr_strong
    case hdr_weak
    case hdr
    case iridescent
    case leak_off
    case leak
    case looks
    case loupe
    case panorama_horizontal
    case panorama_vertical
    case panorama_wide_angle
    case photo_size_select_large
    case photo_size_select_small
    case picture_in_picture
    case slideshow
    case texture
    case tonality
    case vignette
    case wb_auto
    case eject_alt
    case eject
    case equalizer
    case fast_forward
    case fast_rewind
    case forward_10
    case forward_30
    case forward_5
    case hearing
    case pause_circle_outline
    case pause_circle
    case pause
    case play_circle_outline
    case play_circle
    case play
    case playlist_audio
    case playlist_plus
    case repeat_one
    case replay_10
    case replay_30
    case replay_5
    case replay
    case shuffle
    case skip_next
    case skip_previous
    case stop
    case surround_sound
    case tune
    case volume_down
    case volume_mute
    case volume_off
    case volume_up
    case n_1_square
    case n_2_square
    case n_3_square
    case n_4_square
    case n_5_square
    case n_6_square
    case neg_1
    case neg_2
    case plus_1
    case plus_2
    case sec_10
    case sec_3
    case zero
    case airline_seat_flat_angled
    case airline_seat_flat
    case airline_seat_individual_suite
    case airline_seat_legroom_extra
    case airline_seat_legroom_normal
    case airline_seat_legroom_reduced
    case airline_seat_recline_extra
    case airline_seat_recline_normal
    case airplay
    case closed_caption
    case confirmation_number
    case developer_board
    case disc_full
    case explicit
    case flight_land
    case flight_takeoff
    case flip_to_back
    case flip_to_front
    case group_work
    case hd
    case hq
    case markunread_mailbox
    case memory
    case nfc
    case play_for_work
    case power_input
    case present_to_all
    case satellite
    case tap_and_play
    case vibration
    case voicemail
    case group
    case rss
    case shape
    case spinner
    case ungroup
    case amazon
    case blogger
    case delicious
    case disqus
    case flattr
    case flickr
    case github_alt
    case google_old
    case linkedin
    case odnoklassniki
    case outlook
    case paypal_alt
    case pinterest
    case playstation
    case reddit
    case skype
    case slideshare
    case soundcloud
    case tumblr
    case twitch
    case vimeo
    case whatsapp
    case xbox
    case yahoo
    case youtube_play
    case youtube

    var value: String {
        switch self {
        case .airplane_off: return "\u{f102}"
        case .airplane: return "\u{f103}"
        case .album: return "\u{f104}"
        case .archive: return "\u{f105}"
        case .assignment_account: return "\u{f106}"
        case .assignment_alert: return "\u{f107}"
        case .assignment_check: return "\u{f108}"
        case .assignment_o: return "\u{f109}"
        case .assignment_return: return "\u{f10a}"
        case .assignment_returned: return "\u{f10b}"
        case .assignment: return "\u{f10c}"
        case .attachment_alt: return "\u{f10d}"
        case .attachment: return "\u{f10e}"
        case .audio: return "\u{f10f}"
        case .badge_check: return "\u{f110}"
        case .balance_wallet: return "\u{f111}"
        case .balance: return "\u{f112}"
        case .battery_alert: return "\u{f113}"
        case .battery_flash: return "\u{f114}"
        case .battery_unknown: return "\u{f115}"
        case .battery: return "\u{f116}"
        case .bike: return "\u{f117}"
        case .block_alt: return "\u{f118}"
        case .block: return "\u{f119}"
        case .boat: return "\u{f11a}"
        case .book_image: return "\u{f11b}"
        case .book: return "\u{f11c}"
        case .bookmark_outline: return "\u{f11d}"
        case .bookmark: return "\u{f11e}"
        case .brush: return "\u{f11f}"
        case .bug: return "\u{f120}"
        case .bus: return "\u{f121}"
        case .cake: return "\u{f122}"
        case .car_taxi: return "\u{f123}"
        case .car_wash: return "\u{f124}"
        case .car: return "\u{f125}"
        case .card_giftcard: return "\u{f126}"
        case .card_membership: return "\u{f127}"
        case .card_travel: return "\u{f128}"
        case .card: return "\u{f129}"
        case .case_check: return "\u{f12a}"
        case .case_download: return "\u{f12b}"
        case .case_play: return "\u{f12c}"
        case .cast_connected: return "\u{f12e}"
        case .cast: return "\u{f12f}"
        case .chart_donut: return "\u{f130}"
        case .chart: return "\u{f131}"
        case .city_alt: return "\u{f132}"
        case .city: return "\u{f133}"
        case .close_circle_o: return "\u{f134}"
        case .close_circle: return "\u{f135}"
        case .close: return "\u{f136}"
        case .cocktail: return "\u{f137}"
        case .code_setting: return "\u{f138}"
        case .code_smartphone: return "\u{f139}"
        case .code: return "\u{f13a}"
        case .coffee: return "\u{f13b}"
        case .collection_bookmark: return "\u{f13c}"
        case .collection_case_play: return "\u{f13d}"
        case .collection_folder_image: return "\u{f13e}"
        case .collection_image_o: return "\u{f13f}"
        case .collection_image: return "\u{f140}"
        case .collection_item_1: return "\u{f141}"
        case .collection_item_2: return "\u{f142}"
        case .collection_item_3: return "\u{f143}"
        case .collection_item_4: return "\u{f144}"
        case .collection_item_5: return "\u{f145}"
        case .collection_item_6: return "\u{f146}"
        case .collection_item_7: return "\u{f147}"
        case .collection_item_8: return "\u{f148}"
        case .collection_item_9_plus: return "\u{f149}"
        case .collection_item_9: return "\u{f14a}"
        case .collection_item: return "\u{f14b}"
        case .collection_music: return "\u{f14c}"
        case .collection_pdf: return "\u{f14d}"
        case .collection_plus: return "\u{f14e}"
        case .collection_speaker: return "\u{f14f}"
        case .collection_text: return "\u{f150}"
        case .collection_video: return "\u{f151}"
        case .compass: return "\u{f152}"
        case .cutlery: return "\u{f153}"
        case .delete: return "\u{f154}"
        case .dialpad: return "\u{f155}"
        case .dns: return "\u{f156}"
        case .drink: return "\u{f157}"
        case .edit: return "\u{f158}"
        case .email_open: return "\u{f159}"
        case .email: return "\u{f15a}"
        case .eye_off: return "\u{f15b}"
        case .eye: return "\u{f15c}"
        case .eyedropper: return "\u{f15d}"
        case .favorite_outline: return "\u{f15e}"
        case .favorite: return "\u{f15f}"
        case .filter_list: return "\u{f160}"
        case .fire: return "\u{f161}"
        case .flag: return "\u{f162}"
        case .flare: return "\u{f163}"
        case .flash_auto: return "\u{f164}"
        case .flash_off: return "\u{f165}"
        case .flash: return "\u{f166}"
        case .flip: return "\u{f167}"
        case .flower_alt: return "\u{f168}"
        case .flower: return "\u{f169}"
        case .font: return "\u{f16a}"
        case .fullscreen_alt: return "\u{f16b}"
        case .fullscreen_exit: return "\u{f16c}"
        case .fullscreen: return "\u{f16d}"
        case .functions: return "\u{f16e}"
        case .gas_station: return "\u{f16f}"
        case .gesture: return "\u{f170}"
        case .globe_alt: return "\u{f171}"
        case .globe_lock: return "\u{f172}"
        case .globe: return "\u{f173}"
        case .graduation_cap: return "\u{f174}"
        case .home: return "\u{f175}"
        case .hospital_alt: return "\u{f176}"
        case .hospital: return "\u{f177}"
        case .hotel: return "\u{f178}"
        case .hourglass_alt: return "\u{f179}"
        case .hourglass_outline: return "\u{f17a}"
        case .hourglass: return "\u{f17b}"
        case .http: return "\u{f17c}"
        case .image_alt: return "\u{f17d}"
        case .image_o: return "\u{f17e}"
        case .image: return "\u{f17f}"
        case .inbox: return "\u{f180}"
        case .invert_colors_off: return "\u{f181}"
        case .invert_colors: return "\u{f182}"
        case .key: return "\u{f183}"
        case .label_alt_outline: return "\u{f184}"
        case .label_alt: return "\u{f185}"
        case .label_heart: return "\u{f186}"
        case .label: return "\u{f187}"
        case .labels: return "\u{f188}"
        case .lamp: return "\u{f189}"
        case .landscape: return "\u{f18a}"
        case .layers_off: return "\u{f18b}"
        case .layers: return "\u{f18c}"
        case .library: return "\u{f18d}"
        case .link: return "\u{f18e}"
        case .lock_open: return "\u{f18f}"
        case .lock_outline: return "\u{f190}"
        case .lock: return "\u{f191}"
        case .mail_reply_all: return "\u{f192}"
        case .mail_reply: return "\u{f193}"
        case .mail_send: return "\u{f194}"
        case .mall: return "\u{f195}"
        case .map: return "\u{f196}"
        case .menu: return "\u{f197}"
        case .money_box: return "\u{f198}"
        case .money_off: return "\u{f199}"
        case .money: return "\u{f19a}"
        case .more_vert: return "\u{f19b}"
        case .more: return "\u{f19c}"
        case .movie_alt: return "\u{f19d}"
        case .movie: return "\u{f19e}"
        case .nature_people: return "\u{f19f}"
        case .nature: return "\u{f1a0}"
        case .navigation: return "\u{f1a1}"
        case .open_in_browser: return "\u{f1a2}"
        case .open_in_new: return "\u{f1a3}"
        case .palette: return "\u{f1a4}"
        case .parking: return "\u{f1a5}"
        case .pin_account: return "\u{f1a6}"
        case .pin_assistant: return "\u{f1a7}"
        case .pin_drop: return "\u{f1a8}"
        case .pin_help: return "\u{f1a9}"
        case .pin_off: return "\u{f1aa}"
        case .pin: return "\u{f1ab}"
        case .pizza: return "\u{f1ac}"
        case .plaster: return "\u{f1ad}"
        case .power_setting: return "\u{f1ae}"
        case .power: return "\u{f1af}"
        case .print: return "\u{f1b0}"
        case .puzzle_piece: return "\u{f1b1}"
        case .quote: return "\u{f1b2}"
        case .railway: return "\u{f1b3}"
        case .receipt: return "\u{f1b4}"
        case .refresh_alt: return "\u{f1b5}"
        case .refresh_sync_alert: return "\u{f1b6}"
        case .refresh_sync_off: return "\u{f1b7}"
        case .refresh_sync: return "\u{f1b8}"
        case .refresh: return "\u{f1b9}"
        case .roller: return "\u{f1ba}"
        case .ruler: return "\u{f1bb}"
        case .scissors: return "\u{f1bc}"
        case .screen_rotation_lock: return "\u{f1bd}"
        case .screen_rotation: return "\u{f1be}"
        case .search_for: return "\u{f1bf}"
        case .search_in_file: return "\u{f1c0}"
        case .search_in_page: return "\u{f1c1}"
        case .search_replace: return "\u{f1c2}"
        case .search: return "\u{f1c3}"
        case .seat: return "\u{f1c4}"
        case .settings_square: return "\u{f1c5}"
        case .settings: return "\u{f1c6}"
        case .shield_check: return "\u{f1c7}"
        case .shield_security: return "\u{f1c8}"
        case .shopping_basket: return "\u{f1c9}"
        case .shopping_cart_plus: return "\u{f1ca}"
        case .shopping_cart: return "\u{f1cb}"
        case .sign_in: return "\u{f1cc}"
        case .sort_amount_asc: return "\u{f1cd}"
        case .sort_amount_desc: return "\u{f1ce}"
        case .sort_asc: return "\u{f1cf}"
        case .sort_desc: return "\u{f1d0}"
        case .spellcheck: return "\u{f1d1}"
        case .storage: return "\u{f1d2}"
        case .store_24: return "\u{f1d3}"
        case .store: return "\u{f1d4}"
        case .subway: return "\u{f1d5}"
        case .sun: return "\u{f1d6}"
        case .tab_unselected: return "\u{f1d7}"
        case .tab: return "\u{f1d8}"
        case .tag_close: return "\u{f1d9}"
        case .tag_more: return "\u{f1da}"
        case .tag: return "\u{f1db}"
        case .thumb_down: return "\u{f1dc}"
        case .thumb_up_down: return "\u{f1dd}"
        case .thumb_up: return "\u{f1de}"
        case .ticket_star: return "\u{f1df}"
        case .toll: return "\u{f1e0}"
        case .toys: return "\u{f1e1}"
        case .traffic: return "\u{f1e2}"
        case .translate: return "\u{f1e3}"
        case .triangle_down: return "\u{f1e4}"
        case .triangle_up: return "\u{f1e5}"
        case .truck: return "\u{f1e6}"
        case .turning_sign: return "\u{f1e7}"
        case .wallpaper: return "\u{f1e8}"
        case .washing_machine: return "\u{f1e9}"
        case .window_maximize: return "\u{f1ea}"
        case .window_minimize: return "\u{f1eb}"
        case .window_restore: return "\u{f1ec}"
        case .wrench: return "\u{f1ed}"
        case .zoom_in: return "\u{f1ee}"
        case .zoom_out: return "\u{f1ef}"
        case .alert_circle_o: return "\u{f1f0}"
        case .alert_circle: return "\u{f1f1}"
        case .alert_octagon: return "\u{f1f2}"
        case .alert_polygon: return "\u{f1f3}"
        case .alert_triangle: return "\u{f1f4}"
        case .help_outline: return "\u{f1f5}"
        case .help: return "\u{f1f6}"
        case .info_outline: return "\u{f1f7}"
        case .info: return "\u{f1f8}"
        case .notifications_active: return "\u{f1f9}"
        case .notifications_add: return "\u{f1fa}"
        case .notifications_none: return "\u{f1fb}"
        case .notifications_off: return "\u{f1fc}"
        case .notifications_paused: return "\u{f1fd}"
        case .notifications: return "\u{f1fe}"
        case .account_add: return "\u{f1ff}"
        case .account_box_mail: return "\u{f200}"
        case .account_box_o: return "\u{f201}"
        case .account_box_phone: return "\u{f202}"
        case .account_box: return "\u{f203}"
        case .account_calendar: return "\u{f204}"
        case .account_circle: return "\u{f205}"
        case .account_o: return "\u{f206}"
        case .account: return "\u{f207}"
        case .accounts_add: return "\u{f208}"
        case .accounts_alt: return "\u{f209}"
        case .accounts_list_alt: return "\u{f20a}"
        case .accounts_list: return "\u{f20b}"
        case .accounts_outline: return "\u{f20c}"
        case .accounts: return "\u{f20d}"
        case .face: return "\u{f20e}"
        case .female: return "\u{f20f}"
        case .male_alt: return "\u{f210}"
        case .male_female: return "\u{f211}"
        case .male: return "\u{f212}"
        case .mood_bad: return "\u{f213}"
        case .mood: return "\u{f214}"
        case .run: return "\u{f215}"
        case .walk: return "\u{f216}"
        case .cloud_box: return "\u{f217}"
        case .cloud_circle: return "\u{f218}"
        case .cloud_done: return "\u{f219}"
        case .cloud_download: return "\u{f21a}"
        case .cloud_off: return "\u{f21b}"
        case .cloud_outline_alt: return "\u{f21c}"
        case .cloud_outline: return "\u{f21d}"
        case .cloud_upload: return "\u{f21e}"
        case .cloud: return "\u{f21f}"
        case .download: return "\u{f220}"
        case .file_plus: return "\u{f221}"
        case .file_text: return "\u{f222}"
        case .file: return "\u{f223}"
        case .folder_outline: return "\u{f224}"
        case .folder_person: return "\u{f225}"
        case .folder_star_alt: return "\u{f226}"
        case .folder_star: return "\u{f227}"
        case .folder: return "\u{f228}"
        case .gif: return "\u{f229}"
        case .upload: return "\u{f22a}"
        case .border_all: return "\u{f22b}"
        case .border_bottom: return "\u{f22c}"
        case .border_clear: return "\u{f22d}"
        case .border_color: return "\u{f22e}"
        case .border_horizontal: return "\u{f22f}"
        case .border_inner: return "\u{f230}"
        case .border_left: return "\u{f231}"
        case .border_outer: return "\u{f232}"
        case .border_right: return "\u{f233}"
        case .border_style: return "\u{f234}"
        case .border_top: return "\u{f235}"
        case .border_vertical: return "\u{f236}"
        case .copy: return "\u{f237}"
        case .crop: return "\u{f238}"
        case .format_align_center: return "\u{f239}"
        case .format_align_justify: return "\u{f23a}"
        case .format_align_left: return "\u{f23b}"
        case .format_align_right: return "\u{f23c}"
        case .format_bold: return "\u{f23d}"
        case .format_clear_all: return "\u{f23e}"
        case .format_clear: return "\u{f23f}"
        case .format_color_fill: return "\u{f240}"
        case .format_color_reset: return "\u{f241}"
        case .format_color_text: return "\u{f242}"
        case .format_indent_decrease: return "\u{f243}"
        case .format_indent_increase: return "\u{f244}"
        case .format_italic: return "\u{f245}"
        case .format_line_spacing: return "\u{f246}"
        case .format_list_bulleted: return "\u{f247}"
        case .format_list_numbered: return "\u{f248}"
        case .format_ltr: return "\u{f249}"
        case .format_rtl: return "\u{f24a}"
        case .format_size: return "\u{f24b}"
        case .format_strikethrough_s: return "\u{f24c}"
        case .format_strikethrough: return "\u{f24d}"
        case .format_subject: return "\u{f24e}"
        case .format_underlined: return "\u{f24f}"
        case .format_valign_bottom: return "\u{f250}"
        case .format_valign_center: return "\u{f251}"
        case .format_valign_top: return "\u{f252}"
        case .redo: return "\u{f253}"
        case .select_all: return "\u{f254}"
        case .space_bar: return "\u{f255}"
        case .text_format: return "\u{f256}"
        case .transform: return "\u{f257}"
        case .undo: return "\u{f258}"
        case .wrap_text: return "\u{f259}"
        case .comment_alert: return "\u{f25a}"
        case .comment_alt_text: return "\u{f25b}"
        case .comment_alt: return "\u{f25c}"
        case .comment_edit: return "\u{f25d}"
        case .comment_image: return "\u{f25e}"
        case .comment_list: return "\u{f25f}"
        case .comment_more: return "\u{f260}"
        case .comment_outline: return "\u{f261}"
        case .comment_text_alt: return "\u{f262}"
        case .comment_text: return "\u{f263}"
        case .comment_video: return "\u{f264}"
        case .comment: return "\u{f265}"
        case .comments: return "\u{f266}"
        case .check_all: return "\u{f267}"
        case .check_circle_u: return "\u{f268}"
        case .check_circle: return "\u{f269}"
        case .check_square: return "\u{f26a}"
        case .check: return "\u{f26b}"
        case .circle_o: return "\u{f26c}"
        case .circle: return "\u{f26d}"
        case .dot_circle_alt: return "\u{f26e}"
        case .dot_circle: return "\u{f26f}"
        case .minus_circle_outline: return "\u{f270}"
        case .minus_circle: return "\u{f271}"
        case .minus_square: return "\u{f272}"
        case .minus: return "\u{f273}"
        case .plus_circle_o_duplicate: return "\u{f274}"
        case .plus_circle_o: return "\u{f275}"
        case .plus_circle: return "\u{f276}"
        case .plus_square: return "\u{f277}"
        case .plus: return "\u{f278}"
        case .square_o: return "\u{f279}"
        case .star_circle: return "\u{f27a}"
        case .star_half: return "\u{f27b}"
        case .star_outline: return "\u{f27c}"
        case .star: return "\u{f27d}"
        case .bluetooth_connected: return "\u{f27e}"
        case .bluetooth_off: return "\u{f27f}"
        case .bluetooth_search: return "\u{f280}"
        case .bluetooth_setting: return "\u{f281}"
        case .bluetooth: return "\u{f282}"
        case .camera_add: return "\u{f283}"
        case .camera_alt: return "\u{f284}"
        case .camera_bw: return "\u{f285}"
        case .camera_front: return "\u{f286}"
        case .camera_mic: return "\u{f287}"
        case .camera_party_mode: return "\u{f288}"
        case .camera_rear: return "\u{f289}"
        case .camera_roll: return "\u{f28a}"
        case .camera_switch: return "\u{f28b}"
        case .camera: return "\u{f28c}"
        case .card_alert: return "\u{f28d}"
        case .card_off: return "\u{f28e}"
        case .card_sd: return "\u{f28f}"
        case .card_sim: return "\u{f290}"
        case .desktop_mac: return "\u{f291}"
        case .desktop_windows: return "\u{f292}"
        case .device_hub: return "\u{f293}"
        case .devices_off: return "\u{f294}"
        case .devices: return "\u{f295}"
        case .dock: return "\u{f296}"
        case .floppy: return "\u{f297}"
        case .gamepad: return "\u{f298}"
        case .gps_dot: return "\u{f299}"
        case .gps_off: return "\u{f29a}"
        case .gps: return "\u{f29b}"
        case .headset_mic: return "\u{f29c}"
        case .headset: return "\u{f29d}"
        case .input_antenna: return "\u{f29e}"
        case .input_composite: return "\u{f29f}"
        case .input_hdmi: return "\u{f2a0}"
        case .input_power: return "\u{f2a1}"
        case .input_svideo: return "\u{f2a2}"
        case .keyboard_hide: return "\u{f2a3}"
        case .keyboard: return "\u{f2a4}"
        case .laptop_chromebook: return "\u{f2a5}"
        case .laptop_mac: return "\u{f2a6}"
        case .laptop: return "\u{f2a7}"
        case .mic_off: return "\u{f2a8}"
        case .mic_outline: return "\u{f2a9}"
        case .mic_setting: return "\u{f2aa}"
        case .mic: return "\u{f2ab}"
        case .mouse: return "\u{f2ac}"
        case .network_alert: return "\u{f2ad}"
        case .network_locked: return "\u{f2ae}"
        case .network_off: return "\u{f2af}"
        case .network_outline: return "\u{f2b0}"
        case .network_setting: return "\u{f2b1}"
        case .network: return "\u{f2b2}"
        case .phone_bluetooth: return "\u{f2b3}"
        case .phone_end: return "\u{f2b4}"
        case .phone_forwarded: return "\u{f2b5}"
        case .phone_in_talk: return "\u{f2b6}"
        case .phone_locked: return "\u{f2b7}"
        case .phone_missed: return "\u{f2b8}"
        case .phone_msg: return "\u{f2b9}"
        case .phone_paused: return "\u{f2ba}"
        case .phone_ring: return "\u{f2bb}"
        case .phone_setting: return "\u{f2bc}"
        case .phone_sip: return "\u{f2bd}"
        case .phone: return "\u{f2be}"
        case .portable_wifi_changes: return "\u{f2bf}"
        case .portable_wifi_off: return "\u{f2c0}"
        case .portable_wifi: return "\u{f2c1}"
        case .radio: return "\u{f2c2}"
        case .reader: return "\u{f2c3}"
        case .remote_control_alt: return "\u{f2c4}"
        case .remote_control: return "\u{f2c5}"
        case .router: return "\u{f2c6}"
        case .scanner: return "\u{f2c7}"
        case .smartphone_android: return "\u{f2c8}"
        case .smartphone_download: return "\u{f2c9}"
        case .smartphone_erase: return "\u{f2ca}"
        case .smartphone_info: return "\u{f2cb}"
        case .smartphone_iphone: return "\u{f2cc}"
        case .smartphone_landscape_lock: return "\u{f2cd}"
        case .smartphone_landscape: return "\u{f2ce}"
        case .smartphone_lock: return "\u{f2cf}"
        case .smartphone_portrait_lock: return "\u{f2d0}"
        case .smartphone_ring: return "\u{f2d1}"
        case .smartphone_setting: return "\u{f2d2}"
        case .smartphone_setup: return "\u{f2d3}"
        case .smartphone: return "\u{f2d4}"
        case .speaker: return "\u{f2d5}"
        case .tablet_android: return "\u{f2d6}"
        case .tablet_mac: return "\u{f2d7}"
        case .tablet: return "\u{f2d8}"
        case .tv_alt_play: return "\u{f2d9}"
        case .tv_list: return "\u{f2da}"
        case .tv_play: return "\u{f2db}"
        case .tv: return "\u{f2dc}"
        case .usb: return "\u{f2dd}"
        case .videocam_off: return "\u{f2de}"
        case .videocam_switch: return "\u{f2df}"
        case .videocam: return "\u{f2e0}"
        case .watch: return "\u{f2e1}"
        case .wifi_alt_2: return "\u{f2e2}"
        case .wifi_alt: return "\u{f2e3}"
        case .wifi_info: return "\u{f2e4}"
        case .wifi_lock: return "\u{f2e5}"
        case .wifi_off: return "\u{f2e6}"
        case .wifi_outline: return "\u{f2e7}"
        case .wifi: return "\u{f2e8}"
        case .arrow_left_bottom: return "\u{f2e9}"
        case .arrow_left: return "\u{f2ea}"
        case .arrow_merge: return "\u{f2eb}"
        case .arrow_missed: return "\u{f2ec}"
        case .arrow_right_top: return "\u{f2ed}"
        case .arrow_right: return "\u{f2ee}"
        case .arrow_split: return "\u{f2ef}"
        case .arrows: return "\u{f2f0}"
        case .caret_down_circle: return "\u{f2f1}"
        case .caret_down: return "\u{f2f2}"
        case .caret_left_circle: return "\u{f2f3}"
        case .caret_left: return "\u{f2f4}"
        case .caret_right_circle: return "\u{f2f5}"
        case .caret_right: return "\u{f2f6}"
        case .caret_up_circle: return "\u{f2f7}"
        case .caret_up: return "\u{f2f8}"
        case .chevron_down: return "\u{f2f9}"
        case .chevron_left: return "\u{f2fa}"
        case .chevron_right: return "\u{f2fb}"
        case .chevron_up: return "\u{f2fc}"
        case .forward: return "\u{f2fd}"
        case .long_arrow_down: return "\u{f2fe}"
        case .long_arrow_left: return "\u{f2ff}"
        case .long_arrow_return: return "\u{f300}"
        case .long_arrow_right: return "\u{f301}"
        case .long_arrow_tab: return "\u{f302}"
        case .long_arrow_up: return "\u{f303}"
        case .rotate_ccw: return "\u{f304}"
        case .rotate_cw: return "\u{f305}"
        case .rotate_left: return "\u{f306}"
        case .rotate_right: return "\u{f307}"
        case .square_down: return "\u{f308}"
        case .square_right: return "\u{f309}"
        case .swap_alt: return "\u{f30a}"
        case .swap_vertical_circle: return "\u{f30b}"
        case .swap_vertical: return "\u{f30c}"
        case .swap: return "\u{f30d}"
        case .trending_down: return "\u{f30e}"
        case .trending_flat: return "\u{f30f}"
        case .trending_up: return "\u{f310}"
        case .unfold_less: return "\u{f311}"
        case .unfold_more: return "\u{f312}"
        case .apps: return "\u{f313}"
        case .grid_off: return "\u{f314}"
        case .grid: return "\u{f315}"
        case .view_agenda: return "\u{f316}"
        case .view_array: return "\u{f317}"
        case .view_carousel: return "\u{f318}"
        case .view_column: return "\u{f319}"
        case .view_comfy: return "\u{f31a}"
        case .view_compact: return "\u{f31b}"
        case .view_dashboard: return "\u{f31c}"
        case .view_day: return "\u{f31d}"
        case .view_headline: return "\u{f31e}"
        case .view_list_alt: return "\u{f31f}"
        case .view_list: return "\u{f320}"
        case .view_module: return "\u{f321}"
        case .view_quilt: return "\u{f322}"
        case .view_stream: return "\u{f323}"
        case .view_subtitles: return "\u{f324}"
        case .view_toc: return "\u{f325}"
        case .view_web: return "\u{f326}"
        case .view_week: return "\u{f327}"
        case .widgets: return "\u{f328}"
        case .alarm_check: return "\u{f329}"
        case .alarm_off: return "\u{f32a}"
        case .alarm_plus: return "\u{f32b}"
        case .alarm_snooze: return "\u{f32c}"
        case .alarm: return "\u{f32d}"
        case .calendar_alt: return "\u{f32e}"
        case .calendar_check: return "\u{f32f}"
        case .calendar_close: return "\u{f330}"
        case .calendar_note: return "\u{f331}"
        case .calendar: return "\u{f332}"
        case .time_countdown: return "\u{f333}"
        case .time_interval: return "\u{f334}"
        case .time_restore_setting: return "\u{f335}"
        case .time_restore: return "\u{f336}"
        case .time: return "\u{f337}"
        case .timer_off: return "\u{f338}"
        case .timer: return "\u{f339}"
        case .android_alt: return "\u{f33a}"
        case .android: return "\u{f33b}"
        case .apple: return "\u{f33c}"
        case .behance: return "\u{f33d}"
        case .codepen: return "\u{f33e}"
        case .dribbble: return "\u{f33f}"
        case .dropbox: return "\u{f340}"
        case .evernote: return "\u{f341}"
        case .facebook_box: return "\u{f342}"
        case .facebook: return "\u{f343}"
        case .github_box: return "\u{f344}"
        case .github: return "\u{f345}"
        case .google_drive: return "\u{f346}"
        case .google_earth: return "\u{f347}"
        case .google_glass: return "\u{f348}"
        case .google_maps: return "\u{f349}"
        case .google_pages: return "\u{f34a}"
        case .google_play: return "\u{f34b}"
        case .google_plus_box: return "\u{f34c}"
        case .google_plus: return "\u{f34d}"
        case .google: return "\u{f34e}"
        case .instagram: return "\u{f34f}"
        case .language_css3: return "\u{f350}"
        case .language_html5: return "\u{f351}"
        case .language_javascript: return "\u{f352}"
        case .language_python_alt: return "\u{f353}"
        case .language_python: return "\u{f354}"
        case .lastfm: return "\u{f355}"
        case .linkedin_box: return "\u{f356}"
        case .paypal: return "\u{f357}"
        case .pinterest_box: return "\u{f358}"
        case .pocket: return "\u{f359}"
        case .polymer: return "\u{f35a}"
        case .share: return "\u{f35b}"
        case .stackoverflow: return "\u{f35c}"
        case .steam_square: return "\u{f35d}"
        case .steam: return "\u{f35e}"
        case .twitter_box: return "\u{f35f}"
        case .twitter: return "\u{f360}"
        case .vk: return "\u{f361}"
        case .wikipedia: return "\u{f362}"
        case .windows: return "\u{f363}"
        case .aspect_ratio_alt: return "\u{f364}"
        case .aspect_ratio: return "\u{f365}"
        case .blur_circular: return "\u{f366}"
        case .blur_linear: return "\u{f367}"
        case .blur_off: return "\u{f368}"
        case .blur: return "\u{f369}"
        case .brightness_2: return "\u{f36a}"
        case .brightness_3: return "\u{f36b}"
        case .brightness_4: return "\u{f36c}"
        case .brightness_5: return "\u{f36d}"
        case .brightness_6: return "\u{f36e}"
        case .brightness_7: return "\u{f36f}"
        case .brightness_auto: return "\u{f370}"
        case .brightness_setting: return "\u{f371}"
        case .broken_image: return "\u{f372}"
        case .center_focus_strong: return "\u{f373}"
        case .center_focus_weak: return "\u{f374}"
        case .compare: return "\u{f375}"
        case .crop_16_9: return "\u{f376}"
        case .crop_3_2: return "\u{f377}"
        case .crop_5_4: return "\u{f378}"
        case .crop_7_5: return "\u{f379}"
        case .crop_din: return "\u{f37a}"
        case .crop_free: return "\u{f37b}"
        case .crop_landscape: return "\u{f37c}"
        case .crop_portrait: return "\u{f37d}"
        case .crop_square: return "\u{f37e}"
        case .exposure_alt: return "\u{f37f}"
        case .exposure: return "\u{f380}"
        case .filter_b_and_w: return "\u{f381}"
        case .filter_center_focus: return "\u{f382}"
        case .filter_frames: return "\u{f383}"
        case .filter_tilt_shift: return "\u{f384}"
        case .gradient: return "\u{f385}"
        case .grain: return "\u{f386}"
        case .graphic_eq: return "\u{f387}"
        case .hdr_off: return "\u{f388}"
        case .hdr_strong: return "\u{f389}"
        case .hdr_weak: return "\u{f38a}"
        case .hdr: return "\u{f38b}"
        case .iridescent: return "\u{f38c}"
        case .leak_off: return "\u{f38d}"
        case .leak: return "\u{f38e}"
        case .looks: return "\u{f38f}"
        case .loupe: return "\u{f390}"
        case .panorama_horizontal: return "\u{f391}"
        case .panorama_vertical: return "\u{f392}"
        case .panorama_wide_angle: return "\u{f393}"
        case .photo_size_select_large: return "\u{f394}"
        case .photo_size_select_small: return "\u{f395}"
        case .picture_in_picture: return "\u{f396}"
        case .slideshow: return "\u{f397}"
        case .texture: return "\u{f398}"
        case .tonality: return "\u{f399}"
        case .vignette: return "\u{f39a}"
        case .wb_auto: return "\u{f39b}"
        case .eject_alt: return "\u{f39c}"
        case .eject: return "\u{f39d}"
        case .equalizer: return "\u{f39e}"
        case .fast_forward: return "\u{f39f}"
        case .fast_rewind: return "\u{f3a0}"
        case .forward_10: return "\u{f3a1}"
        case .forward_30: return "\u{f3a2}"
        case .forward_5: return "\u{f3a3}"
        case .hearing: return "\u{f3a4}"
        case .pause_circle_outline: return "\u{f3a5}"
        case .pause_circle: return "\u{f3a6}"
        case .pause: return "\u{f3a7}"
        case .play_circle_outline: return "\u{f3a8}"
        case .play_circle: return "\u{f3a9}"
        case .play: return "\u{f3aa}"
        case .playlist_audio: return "\u{f3ab}"
        case .playlist_plus: return "\u{f3ac}"
        case .repeat_one: return "\u{f3ad}"
        case .replay_10: return "\u{f3af}"
        case .replay_30: return "\u{f3b0}"
        case .replay_5: return "\u{f3b1}"
        case .replay: return "\u{f3b2}"
        case .shuffle: return "\u{f3b3}"
        case .skip_next: return "\u{f3b4}"
        case .skip_previous: return "\u{f3b5}"
        case .stop: return "\u{f3b6}"
        case .surround_sound: return "\u{f3b7}"
        case .tune: return "\u{f3b8}"
        case .volume_down: return "\u{f3b9}"
        case .volume_mute: return "\u{f3ba}"
        case .volume_off: return "\u{f3bb}"
        case .volume_up: return "\u{f3bc}"
        case .n_1_square: return "\u{f3bd}"
        case .n_2_square: return "\u{f3be}"
        case .n_3_square: return "\u{f3bf}"
        case .n_4_square: return "\u{f3c0}"
        case .n_5_square: return "\u{f3c1}"
        case .n_6_square: return "\u{f3c2}"
        case .neg_1: return "\u{f3c3}"
        case .neg_2: return "\u{f3c4}"
        case .plus_1: return "\u{f3c5}"
        case .plus_2: return "\u{f3c6}"
        case .sec_10: return "\u{f3c7}"
        case .sec_3: return "\u{f3c8}"
        case .zero: return "\u{f3c9}"
        case .airline_seat_flat_angled: return "\u{f3ca}"
        case .airline_seat_flat: return "\u{f3cb}"
        case .airline_seat_individual_suite: return "\u{f3cc}"
        case .airline_seat_legroom_extra: return "\u{f3cd}"
        case .airline_seat_legroom_normal: return "\u{f3ce}"
        case .airline_seat_legroom_reduced: return "\u{f3cf}"
        case .airline_seat_recline_extra: return "\u{f3d0}"
        case .airline_seat_recline_normal: return "\u{f3d1}"
        case .airplay: return "\u{f3d2}"
        case .closed_caption: return "\u{f3d3}"
        case .confirmation_number: return "\u{f3d4}"
        case .developer_board: return "\u{f3d5}"
        case .disc_full: return "\u{f3d6}"
        case .explicit: return "\u{f3d7}"
        case .flight_land: return "\u{f3d8}"
        case .flight_takeoff: return "\u{f3d9}"
        case .flip_to_back: return "\u{f3da}"
        case .flip_to_front: return "\u{f3db}"
        case .group_work: return "\u{f3dc}"
        case .hd: return "\u{f3dd}"
        case .hq: return "\u{f3de}"
        case .markunread_mailbox: return "\u{f3df}"
        case .memory: return "\u{f3e0}"
        case .nfc: return "\u{f3e1}"
        case .play_for_work: return "\u{f3e2}"
        case .power_input: return "\u{f3e3}"
        case .present_to_all: return "\u{f3e4}"
        case .satellite: return "\u{f3e5}"
        case .tap_and_play: return "\u{f3e6}"
        case .vibration: return "\u{f3e7}"
        case .voicemail: return "\u{f3e8}"
        case .group: return "\u{f3e9}"
        case .rss: return "\u{f3ea}"
        case .shape: return "\u{f3eb}"
        case .spinner: return "\u{f3ec}"
        case .ungroup: return "\u{f3ed}"
        case .amazon: return "\u{f3f0}"
        case .blogger: return "\u{f3f1}"
        case .delicious: return "\u{f3f2}"
        case .disqus: return "\u{f3f3}"
        case .flattr: return "\u{f3f4}"
        case .flickr: return "\u{f3f5}"
        case .github_alt: return "\u{f3f6}"
        case .google_old: return "\u{f3f7}"
        case .linkedin: return "\u{f3f8}"
        case .odnoklassniki: return "\u{f3f9}"
        case .outlook: return "\u{f3fa}"
        case .paypal_alt: return "\u{f3fb}"
        case .pinterest: return "\u{f3fc}"
        case .playstation: return "\u{f3fd}"
        case .reddit: return "\u{f3fe}"
        case .skype: return "\u{f3ff}"
        case .slideshare: return "\u{f400}"
        case .soundcloud: return "\u{f401}"
        case .tumblr: return "\u{f402}"
        case .twitch: return "\u{f403}"
        case .vimeo: return "\u{f404}"
        case .whatsapp: return "\u{f405}"
        case .xbox: return "\u{f406}"
        case .yahoo: return "\u{f407}"
        case .youtube_play: return "\u{f408}"
        case .youtube: return "\u{f409}"
        }
    }
    var name: String {
        return "\(self)"
    }
}

//
//  UIFont.swift
//  gexOfficial
//
//  Created by kodai ozawa on 2017/11/09.
//  Copyright © 2017 conol. All rights reserved.
//

import UIKit

enum FontSize: CGFloat {
    /// 18
    case xl = 18
    /// 15
    case l = 16
    /// 14
    case m = 14
    /// 12
    case s = 12
    /// 10
    case xs = 10
    /// 8
    case xxs = 8
}

extension UIFont {

    private enum Const {
        public static let iconName = "Material-Design-Iconic-Font"
        public static let fontNameW3 = "HiraKakuProN-W3"
        public static let fontNameW6 = "HiraKakuProN-W6"
        public static let fontNumber = "Lato-Regular"
    }

    class func icon(type: FontSize) -> UIFont {
        return self.icon(size: type.rawValue)
    }

    class func icon(size: CGFloat) -> UIFont {
        return UIFont(name: Const.iconName, size: size)!
    }

    class func light(type: FontSize) -> UIFont {
        return self.light(size: type.rawValue)
    }

    class func light(size: CGFloat) -> UIFont {
        return UIFont(name: Const.fontNameW3, size: size)!
    }

    class func semiBold(type: FontSize) -> UIFont {
        return self.semiBold(size: type.rawValue)
    }

    class func semiBold(size: CGFloat) -> UIFont {
        return UIFont(name: Const.fontNameW6, size: size)!
    }

    class func number(type: FontSize) -> UIFont {
        return self.number(size: type.rawValue)
    }

    class func number(size: CGFloat) -> UIFont {
        return UIFont(name: Const.fontNumber, size: size)!
    }
}

import Foundation

protocol CatalogueType: RawRepresentable {

    static var sequence: AnySequence<Self> { get }

    static var values: [Self] { get }
}

extension CatalogueType where Self.RawValue == Int {

    fileprivate typealias Element = Self

    static var sequence: AnySequence<Self> {
        return AnySequence { () -> AnyIterator<Element> in
            var i = 0
            return AnyIterator { () -> Element? in
                let e = Element(rawValue: i)
                i += 1
                return e
            }
        }
    }

    static var values: [Self] {
        return Array(self.sequence)
    }

    init(value: Self.RawValue) {
        guard let row = Self(rawValue: value) else {
            fatalError("Unimplemented value \(value)")
        }
        self = row
    }
}
