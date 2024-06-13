import Foundation

class DownloadService {
  //
  var activeDownloads: [URL: Download] = [ : ]
  var downloadsSession: URLSession!
  
    func startDownload(_ track: Track, index: Int) {
        let download = Download(track: track, index: index)
        let fileURL = URL(string: track.file!)
        download.task = downloadsSession.downloadTask(with: fileURL!)
        download.task?.resume()
        download.isDownloading = true
        activeDownloads[URL(string:download.track.file!)!] = download
    }
    
    // added methods
    static func delete(_ track: Track){
        if let audioUrl = URL(string: track.file!) {
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                do {
                    try FileManager.default.removeItem(at: destinationUrl)
                } catch let error as NSError {
                    print("error: \(error.localizedDescription)")
                }
            } else {
                return
            }
        }
    }
    
}
