import WeScan
import Flutter
import Foundation

class HomeViewController: UIViewController, ImageScannerControllerDelegate {
    var _result:FlutterResult?

    override func viewDidAppear(_ animated: Bool) {
        if self.isBeingPresented {
            let scannerVC = ImageScannerController()
            scannerVC.imageScannerDelegate = self
            scannerVC.modalPresentationStyle = .fullScreen
            scannerVC.modalTransitionStyle = .crossDissolve
            if #available(iOS 13.0, *) {
                scannerVC.navigationBar.tintColor = .label
            } else {
                scannerVC.navigationBar.tintColor = .black
            }

            if #available(iOS 15, *) {
                let appearance = UINavigationBarAppearance()
                let navigationBar = UINavigationBar()
                appearance.configureWithOpaqueBackground()
                appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
                //appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                //appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: .systemForeground]
                //appearance.backgroundColor = UIColor(red: 72/255.0, green: 72/255.0, blue: 74/255.0, alpha: 1.0)
                appearance.backgroundColor = .systemBackground
                navigationBar.standardAppearance = appearance;
                UINavigationBar.appearance().scrollEdgeAppearance = appearance

                let appearanceTB = UITabBarAppearance()
                //let UITabBarUITabBar = UITabBar()
                appearanceTB.configureWithOpaqueBackground()
                appearanceTB.backgroundColor = .systemBackground
                UITabBar.appearance().standardAppearance = appearanceTB
                UITabBar.appearance().scrollEdgeAppearance = appearanceTB
            }
            present(scannerVC, animated: true, completion: nil)
        }
    }

    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        print(error)
        _result!(nil)
        self.dismiss(animated: true)
    }

    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        // Your ViewController is responsible for dismissing the ImageScannerController
        scanner.dismiss(animated: true)
        let imagePath = saveImage(image:results.croppedScan.image)
        _result!(imagePath)
        self.dismiss(animated: true)
    }

    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        // Your ViewController is responsible for dismissing the ImageScannerController
        scanner.dismiss(animated: true)
        _result!(nil)
        self.dismiss(animated: true)
    }

    func saveImage(image: UIImage) -> String? {

        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return nil
        }

        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return nil
        }

        let fileName = randomString(length:10);
        let filePath: URL = directory.appendingPathComponent(fileName + ".png")!
        do {
            let fileManager = FileManager.default
            // Check if file exists
            if fileManager.fileExists(atPath: filePath.path) {
                // Delete file
                try fileManager.removeItem(atPath: filePath.path)
            }
            else {
                print("File does not exist")
            }
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
        do {
            try data.write(to: filePath)
            return filePath.path
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
}
