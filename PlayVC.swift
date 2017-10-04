//
//  FirstViewController.swift
//  Bok
//
//  Created by Joe Kletz on 03/08/2017.
//  Copyright © 2017 Joe Kletz. All rights reserved.
//



import UIKit
import AVFoundation
import KDEAudioPlayer

class PlayVC: UIViewController {
    
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var coverButton:UIButton!
    
    @IBOutlet weak var inTimeLabel:UILabel!
    @IBOutlet weak var outTimeLabel:UILabel!
    
    @IBOutlet var playbackSlider:UISlider!
    
    @IBOutlet weak var playButton:UIButton!
    
    @IBOutlet weak var profileButton:UIButton!
    
    var playerItem:AVPlayerItem?
    var player:AVPlayer?
    
    var timer:Timer?

    var explorerImage:NoSelectionView?
    
    
    let kdePlayer = AudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newSetupPlayer()
        
        profileButton.layer.cornerRadius = profileButton.frame.width / 2
        
        kdePlayer.delegate = self as AudioPlayerDelegate
        
        addExploreImage()
    }
    
    func addExploreImage() {
        explorerImage = UIView.fromNib()
        explorerImage?.translatesAutoresizingMaskIntoConstraints = false
        coverButton.addSubview(explorerImage!)
        
        let horizontalConstraint = explorerImage?.centerXAnchor.constraint(equalTo: coverButton.centerXAnchor)
        let verticalConstraint = explorerImage?.centerYAnchor.constraint(equalTo: coverButton.centerYAnchor)
        NSLayoutConstraint.activate([horizontalConstraint!, verticalConstraint!])
    }

    
    override func viewWillAppear(_ animated: Bool) {
        if let title = LibraryVC.selectedBook?.book?.title{
            titleLabel.text = title
        }
        
        if let coverURL = LibraryVC.selectedBook?.book?.cover{
            downloadImage(url: URL(string: coverURL)!)
            
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                //imageView.image = UIImage(data: data)
                
                self.explorerImage?.isHidden = true
                
                let image = UIImage(data: data)
                self.coverButton.imageView?.contentMode = .scaleAspectFill
                self.coverButton.setImage(image, for: .normal)
            }
        }
    }
    
    var item = AudioItem()
    
    func newSetupPlayer() {
        let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/bokapp-9d5af.appspot.com/o/Test%2Fkukushka.mp3?alt=media&token=15fcde9d-0700-4598-8003-a9d829fb17f1")
        item = AudioItem(mediumQualitySoundURL: url)
    }

    func playPauseAction() {
        switch kdePlayer.state {
        case .buffering :
            kdePlayer.play(item: item!)
        case .playing :
            kdePlayer.pause()
        case .paused :
            kdePlayer.resume()
        case .stopped:
            kdePlayer.play(item: item!)
            break
        default:
            print(kdePlayer.state)
            break
        }
    }
    
    func populateLabelWithTime(_ label : UILabel, time: Double) {
        let minutes = Int(time / 60)
        let seconds = Int(time) - minutes * 60
        
        label.text = String(format: "%2d", minutes) + ":" + String(format: "%02d", seconds)
    }
    
    
    @IBAction func pressesPlay(){
        playPauseAction()
    }
    
    @IBAction func skipForward(){
        let time = kdePlayer.currentItemProgression
        kdePlayer.seek(to: Double(time!) + 30)
    }
    
    @IBAction func skipBack(){
        let time = kdePlayer.currentItemProgression
        kdePlayer.seek(to: Double(time!) - 30)
    }
    
    @IBAction func previous(){
        
        
        /*
        player?.seek(to: kCMTimeZero, completionHandler: { (finished) in
            self.player?.play()
            self.getTime()
        })*/
    }
    
    

    @IBAction func sliderDragged(){

        if let duration = kdePlayer.currentItemDuration{
            kdePlayer.seek(to: Double(playbackSlider.value) * duration)
        }

    }
    
    @IBAction func options(){
        showOptions()
    }
    
    @IBAction func sleepPressed(){
        sleepOptions()
    }
    
    func showOptions() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let someAction = UIAlertAction(title: "Info", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(someAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func sleepOptions() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionA = UIAlertAction(title: "5", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        let actionB = UIAlertAction(title: "10", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        let actionC = UIAlertAction(title: "15", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(actionA)
        optionMenu.addAction(actionB)
        optionMenu.addAction(actionC)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }

    @IBAction func toChapters(){
        performSegue(withIdentifier: "toChapters", sender: nil)
    }
    
}

class PlaybackSlider: UISlider {
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var result = super.trackRect(forBounds: bounds)
        result.origin.x = 0
        result.size.width = bounds.size.width
        result.size.height = 8 //added height for desired effect
        return result
    }
}

extension PlayVC:AudioPlayerDelegate{
    
    func audioPlayer(_ audioPlayer: AudioPlayer, willStartPlaying item: AudioItem) {
        
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didLoad range: TimeRange, for item: AudioItem) {
        
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didFindDuration duration: TimeInterval, for item: AudioItem) {
        
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateProgressionTo time: TimeInterval, percentageRead: Float) {
        
        populateLabelWithTime(inTimeLabel, time: kdePlayer.currentItemProgression!)
        populateLabelWithTime(outTimeLabel, time: kdePlayer.currentItemDuration! - kdePlayer.currentItemProgression!)

            if let currTime = kdePlayer.currentItemProgression, let duration = kdePlayer.currentItemDuration{
                let value = Float(currTime / duration)
                playbackSlider.value = value
            }
        
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState) {
        
        print("STATE CHANGE FROM",from)
        print("STATE CHANGE TO",state)

        
        var image = #imageLiteral(resourceName: "pause")
        switch state {
        case .playing:
            image = #imageLiteral(resourceName: "pause")
        case .buffering:
            image = #imageLiteral(resourceName: "help")
        case .paused:
            image = #imageLiteral(resourceName: "play")
        default:
            image = #imageLiteral(resourceName: "pause")
        }
        playButton.setImage(image, for: UIControlState())
        
        
        
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateEmptyMetadataOn item: AudioItem, withData data: Metadata) {
        
    }
}


