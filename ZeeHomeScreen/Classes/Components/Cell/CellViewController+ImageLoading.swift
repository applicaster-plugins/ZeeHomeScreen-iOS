import Kingfisher

extension CellViewController {
    public func setImage(to imageView: UIImageView,
                         url: URL?, maskImage: UIImage?,
                         fallbackImage: UIImage?,
                         placeholderImage: UIImage?,
                         serverResizable: Bool) {
        // update placeholder image with masked image
        var updatedPlaceholderImage = placeholderImage
        if let maskImage = maskImage,
            updatedPlaceholderImage != nil {
            updatedPlaceholderImage = UIImage.getCropped(placeholderImage, withMask: maskImage)
        }

        guard let imageUrl = url else {
            imageView.image = updatedPlaceholderImage
            return
        }
        let downloader = ImageDownloader(name: "image_downloader")
        downloader.downloadTimeout = 30.0

        if imageView.contentMode == .center {
            imageView.contentMode = .scaleAspectFit
        }

        if url?.isFileURL == true,
            let urlPath = url?.path {
            let image = UIImage(contentsOfFile: urlPath)

            updateImage(on: imageView,
                        with: image,
                        maskImage: maskImage,
                        fallbackImage: fallbackImage)
        } else if url?.pathExtension == "gif" {
            setAnimatedImage(forImageView: imageView,
                             url: url)
        } else {
            numberOfImageFetchingOperationsInProgress += 1
            imageView.kf.setImage(with: imageUrl,
                                  placeholder: updatedPlaceholderImage,
                                  options: [.downloader(downloader),
                                            .diskCacheExpiration(self.diskCacheExpiration()),
                                            .targetCache(ImageCache.default),
                                            .scaleFactor(UIScreen.main.scale),
                                            .transition(.fade(1)),
                                            .backgroundDecode,
                                            .processor(DownsamplingImageProcessor(size: imageView.size))],
                                  completionHandler: { result in
                                    
                                    if (self.numberOfImageFetchingOperationsInProgress == 1) {
                                        var resultImage: UIImage?
                                        switch result {
                                        case let .success(value):
                                          resultImage = value.image

                                        case .failure:
                                          break
                                        }

                                        self.updateImage(on: imageView,
                                                       with: resultImage,
                                                       maskImage: maskImage,
                                                       fallbackImage: fallbackImage)
                                    }
                                    
                                    self.numberOfImageFetchingOperationsInProgress -= 1
            })
        }
    }
    
    private func updateImage(on imageView: UIImageView,
                             with image: UIImage?,
                             maskImage: UIImage?,
                             fallbackImage: UIImage?) {
        var needImageUpdate = false
        var currentImage = image

        // set fallback image if not image was set
        if currentImage == nil, fallbackImage != nil {
            currentImage = fallbackImage
            needImageUpdate = true
        }

        // set maskImage if exists
        if currentImage != nil {
            if maskImage != nil {
                currentImage = UIImage.getCropped(image, withMask: maskImage)
            }

            needImageUpdate = true
        }

        // update image if needed
        if needImageUpdate {
            imageView.image = currentImage
        }

        if let imageView = imageView as? AnimatedImageView,
            imageView.isAnimating {
            imageView.startAnimating()
        }
    }
    
    public func setAnimatedImage(forImageView imageView: UIImageView,
                                 url: URL?) {
        guard let url = url else {
            return
        }
        
        let request = URLRequest(url: url,
                                 cachePolicy: .returnCacheDataElseLoad,
                                 timeoutInterval: 30)

        APNetworkManager.requestDataObject(forRequest: request) { _, responseObject, error, _ in
            if error == nil,
                let animatedImage = FLAnimatedImage(imageData: responseObject) {
                imageView.image = animatedImage
            }
        }
    }
    
    fileprivate func diskCacheExpiration() -> StorageExpiration {
        return .days(7)
    }
}
