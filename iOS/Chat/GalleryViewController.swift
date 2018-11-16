//
//  GalleryViewController.swift
//  Clerkie
//
//  Created by Nil Puig on 16/11/2018.
//  Copyright © 2018 Nil Puig. All rights reserved.
//

import UIKit
import Photos
import AVFoundation


protocol SelectedImageDelegate {
    func imageUploaded(selectedImage: UIImage)
    func videoUploaded(thumbnail: UIImage, duration: Float, localURL: URL)
}



class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    struct videoObject {
        var videoURL: URL?
        var thumbnail: UIImage?
        var duration: Float?
    }
    
    var PhotosArray = [UIImage]()
    var VideosArray = [videoObject]()
    
    let CELL_IDENTIFIER = "GalleryCell"
    var imageSelectedDelegate: SelectedImageDelegate!
    
    var isPhotosTab = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        grabPhotos()
        
        let placeHolderTapped = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        placeHolderView.addGestureRecognizer(placeHolderTapped)
        
        let photoTabTapped = UITapGestureRecognizer(target: self, action: #selector(onPhotosTapped))
        photoTabContainer.addGestureRecognizer(photoTabTapped)
        
        let videoTabTapped = UITapGestureRecognizer(target: self, action: #selector(onVideoTapped))
        videoTabContainer.addGestureRecognizer(videoTabTapped)
    }

    @objc private func dismissVC() {
        placeHolderView.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func onPhotosTapped()
    {
        isPhotosTab = true
        toggleSelectionView()
    }
    
    @objc private func onVideoTapped()
    {
        isPhotosTab = false
        toggleSelectionView()
    }
    

    private func grabPhotos()
    {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .opportunistic
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        if (fetchResult.count > 0)
        {
            // We have images
            for i in 0..<fetchResult.count
            {
                imageManager.requestImage(for: fetchResult.object(at: i), targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFit , options: requestOptions)
                { (image, error) in
                    self.PhotosArray.append(image!)
                }
            }
        }
        else {
            self.galleryCollectionView.reloadData()
        }
        
        

        let requestVideoOptions = PHVideoRequestOptions()
        requestVideoOptions.deliveryMode = .automatic

        let fetchVideosResults: PHFetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        if(fetchVideosResults.count > 0) {
            for i in 0..<fetchVideosResults.count
            {
                imageManager.requestAVAsset(forVideo: fetchVideosResults.object(at: i), options: requestVideoOptions) { (asset, audiomix, info) in
                    if let urlAsset = asset as? AVURLAsset {
                        let localVideoUrl: URL = urlAsset.url as URL
                        let duration: Float = Float(CMTimeGetSeconds(urlAsset.duration))
                        
                        let videoObj = videoObject(videoURL: localVideoUrl, thumbnail: nil, duration: duration)
                        self.VideosArray.append(videoObj)
                    }
                }
            }
        }
    }
    
    
      private func thumbnailForVideoAtURL(url: URL) -> UIImage? {
        
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print("error")
            return nil
        }
    }
    
    
    private func toggleSelectionView() {
        var colorOne: UIColor?
        var colorTwo: UIColor?
        
        if (isPhotosTab) {
            colorOne = UIColor.white
            colorTwo = UIColor.main
        }
            
        else {
            colorOne = UIColor.main
            colorTwo = UIColor.white
        }
        
        photoTabLabel.textColor = colorOne
        photoTabContainer.backgroundColor = colorTwo
        
        videoTabLabel.textColor = colorTwo
        videoTabContainer.backgroundColor = colorOne
        
        galleryCollectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isPhotosTab ? PhotosArray.count: VideosArray.count
    }
    

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER, for: indexPath) as! PictureCell
        
        var poster: UIImage?
        
        if(isPhotosTab)
        {
            poster = PhotosArray[indexPath.row]
        }
            
        else
        {
            if(VideosArray[indexPath.row].thumbnail == nil)
            {
                poster = thumbnailForVideoAtURL(url: VideosArray[indexPath.row].videoURL!)
                VideosArray[indexPath.row].thumbnail = poster
            }
            else
            {
                poster = VideosArray[indexPath.row].thumbnail
            }
        }
        
        cell.pictureImageView.image = poster
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let currentCell = collectionView.cellForItem(at: indexPath) as! PictureCell
        
        UIView.animate(withDuration: 0.3) {
            let move = currentCell.frame.height / 4
            currentCell.transform = CGAffineTransform(translationX: move, y: move)
        }
        
        currentCell.frame.size.height = 0
        currentCell.frame.size.width = 0
        
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            currentCell.alpha = 0
        }, completion: { (true) in
            
            if(self.isPhotosTab)
            {
                self.imageSelectedDelegate.imageUploaded(selectedImage: self.PhotosArray[indexPath.row])
            }
            else
            {
                let myVideoObj: videoObject = self.VideosArray[indexPath.row]
                self.imageSelectedDelegate.videoUploaded(thumbnail: myVideoObj.thumbnail!, duration: myVideoObj.duration!, localURL: myVideoObj.videoURL!)
            }
            
            self.dismissVC()
        })
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let height = galleryCollectionView.frame.height
        return CGSize(width: height, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }

    var placeHolderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        return view
    }()

    
    var photoVideoToggleContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.red
        
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.main.cgColor
        
        return view
    }()
    

    var photoTabContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.main
        return view
    }()
    
    var photoTabLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Photos"
        label.textAlignment = .center
        label.textColor = UIColor.white
        return label
    }()
    
    
    var videoTabContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    

  var videoTabLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Video"
        label.textAlignment = .center
        label.textColor = UIColor.main
        return label
    }()

    
    var pickerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        return view
    }()

    
    lazy var galleryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(PictureCell.self, forCellWithReuseIdentifier: CELL_IDENTIFIER)
        cv.backgroundColor = .white
        return cv

    }()
    
    
    private func setupViews() {
        view.addSubview(placeHolderView)
        placeHolderView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        placeHolderView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        placeHolderView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        placeHolderView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        view.addSubview(pickerContainerView)
        pickerContainerView.topAnchor.constraint(equalTo: placeHolderView.bottomAnchor).isActive = true
        pickerContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        pickerContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        pickerContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        makePhotoVideoToggleView()

        pickerContainerView.addSubview(galleryCollectionView)
        galleryCollectionView.topAnchor.constraint(equalTo: photoVideoToggleContainer.bottomAnchor, constant: 5).isActive = true
        galleryCollectionView.leftAnchor.constraint(equalTo: pickerContainerView.leftAnchor, constant: 8).isActive = true
        galleryCollectionView.rightAnchor.constraint(equalTo: pickerContainerView.rightAnchor, constant: -8).isActive = true
        galleryCollectionView.bottomAnchor.constraint(equalTo: pickerContainerView.bottomAnchor, constant: -8).isActive = true
        galleryCollectionView.widthAnchor.constraint(equalTo: pickerContainerView.widthAnchor, constant: -16).isActive = true
        galleryCollectionView.heightAnchor.constraint(equalTo: pickerContainerView.heightAnchor, multiplier: 0.85, constant: -18).isActive = true
        
        
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        
    }


    private func makePhotoVideoToggleView() {
        pickerContainerView.addSubview(photoVideoToggleContainer)
        photoVideoToggleContainer.topAnchor.constraint(equalTo: pickerContainerView.topAnchor, constant: 5).isActive = true
        photoVideoToggleContainer.widthAnchor.constraint(equalTo: pickerContainerView.widthAnchor, multiplier: 0.6).isActive = true
        photoVideoToggleContainer.centerXAnchor.constraint(equalTo: pickerContainerView.centerXAnchor).isActive = true
        photoVideoToggleContainer.heightAnchor.constraint(equalTo: pickerContainerView.heightAnchor, multiplier: 0.15).isActive = true
        
        photoVideoToggleContainer.addSubview(photoTabContainer)
        photoTabContainer.heightAnchor.constraint(equalTo: photoVideoToggleContainer.heightAnchor).isActive = true
        photoTabContainer.widthAnchor.constraint(equalTo: photoVideoToggleContainer.widthAnchor, multiplier: 0.5).isActive = true
        photoTabContainer.leftAnchor.constraint(equalTo: photoVideoToggleContainer.leftAnchor).isActive = true
        photoTabContainer.rightAnchor.constraint(equalTo: photoVideoToggleContainer.centerXAnchor).isActive = true
        photoTabContainer.centerYAnchor.constraint(equalTo: photoVideoToggleContainer.centerYAnchor).isActive = true
        
        photoTabContainer.addSubview(photoTabLabel)
        photoTabLabel.centerYAnchor.constraint(equalTo: photoTabContainer.centerYAnchor).isActive = true
        photoTabLabel.centerXAnchor.constraint(equalTo: photoTabContainer.centerXAnchor).isActive = true
        
        
        photoVideoToggleContainer.addSubview(videoTabContainer)
        videoTabContainer.heightAnchor.constraint(equalTo: photoVideoToggleContainer.heightAnchor).isActive = true
        videoTabContainer.widthAnchor.constraint(equalTo: photoVideoToggleContainer.widthAnchor, multiplier: 0.5).isActive = true
        videoTabContainer.leftAnchor.constraint(equalTo: photoVideoToggleContainer.centerXAnchor).isActive = true
        videoTabContainer.rightAnchor.constraint(equalTo: photoVideoToggleContainer.rightAnchor).isActive = true
        videoTabContainer.centerYAnchor.constraint(equalTo: photoVideoToggleContainer.centerYAnchor).isActive = true
        
        videoTabContainer.addSubview(videoTabLabel)
        videoTabLabel.centerYAnchor.constraint(equalTo: videoTabContainer.centerYAnchor).isActive = true
        videoTabLabel.centerXAnchor.constraint(equalTo: videoTabContainer.centerXAnchor).isActive = true
    }
    
    
}





