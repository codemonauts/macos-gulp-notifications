//
//  AppDelegate.swift
//  GulpNotifications
//
//  Created by Thomas Schulze on 07.10.17.
//  Copyright © 2017 codemonauts UG (haftungsbeschränkt). All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, GCDAsyncUdpSocketDelegate, NSUserNotificationCenterDelegate {

    struct GulpMessage {
        var title: String
        var information: String
        var error: Bool
    }
    
    private var _socket: GCDAsyncUdpSocket?
    
    private var socket: GCDAsyncUdpSocket? {
        get {
            if _socket == nil {
                _socket = getNewSocket()
            }
            return _socket
        }
        set {
            if _socket != nil {
                _socket?.close()
            }
            _socket = newValue
        }
    }
    
    private func getNewSocket() -> GCDAsyncUdpSocket? {
        let port = 9090
        let sock = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try sock.bind(toPort: UInt16(port))
            try sock.enableBroadcast(true)
        } catch _ as NSError {
            return nil
        }
        return sock
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        do {
            try socket?.beginReceiving()
        } catch _ as NSError {
            print("Issue starting listener")
            return
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if socket != nil {
            socket?.pauseReceiving()
        }
    }
    
    func messageFromJSONData(_ data: Data) -> GulpMessage? {
        typealias JSONDict = [String:AnyObject]
        let json : JSONDict
    
        do {
            json = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDict
        } catch {
            return nil
        }
        
        let message = GulpMessage(
            title: json["title"] as! String,
            information: json["information"] as! String,
            error: json["error"] as! Bool
        )
        
        return message
    }
    
    func showNotification(message: GulpMessage!) -> Void {
        if (message != nil) {
            let notification = NSUserNotification()
            notification.title = message.title
            notification.informativeText = message.information
            notification.soundName = NSUserNotificationDefaultSoundName
            NSUserNotificationCenter.default.deliver(notification)
        }
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let response = "Ok"
        let message = messageFromJSONData(data)
        self.showNotification(message: message)
        sock.send(response.data(using: String.Encoding.utf8)!, toAddress: address, withTimeout: 2, tag: 0)
    }
}
