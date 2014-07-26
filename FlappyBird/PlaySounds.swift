//
//  PlaySounds.swift
//  FlappyBird
//
//  Created by tt on 2014/07/26.
//  Copyright (c) 2014年 Fullstack.io. All rights reserved.
//

import AVFoundation

class PlaySounds{
    var se = Dictionary<String, AVAudioPlayer>()
    var bgm = Dictionary<String, AVAudioPlayer>()

    
    // Initialize
    init(){
        // SE ここで読み込みたいファイルを登録
        self.se["jump"] = AVAudioPlayer()
        self.se["death"] = AVAudioPlayer()
        self.se["powerup"] = AVAudioPlayer()
        
        for name in se.keys {
            self.se[name] = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(name, ofType: "caf")), error: nil)
            self.se[name]?.prepareToPlay()
        }
        
        
        
        // BGM
        self.bgm["default"] = AVAudioPlayer()
        
        for name in bgm.keys {
            self.bgm[name] = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(name, ofType: "caf")), error: nil)
            self.bgm[name]?.prepareToPlay()
        }
    }
    
    
    // ゲームオーバーしたときに呼び出す
    func reset(){
        for name in se.keys {
            self.se[name]?.stop()
            self.se[name]!.currentTime = 0
        }
    
        for name in bgm.keys {
            self.bgm[name]?.stop()
            self.bgm[name]!.currentTime = 0
        }
        
        playBGM("default")
    }
    
    
    // SEを再生する(引数:ファイル名)
    func playSE(se_name:String){
        if se[se_name] != nil {
            self.se[se_name]?.stop()
            self.se[se_name]!.currentTime = 0
            self.se[se_name]?.play()
        }
    }

    // BGMを再生する(引数:ファイル名)
    func playBGM(bgm_name:String){
        if bgm[bgm_name] != nil {
            for name in bgm.keys {
                self.bgm[name]?.stop()
                self.bgm[name]!.currentTime = 0
            }

            self.bgm[bgm_name]?.play()
        }
    }
    
    // BGMを停止する
    func stopBGM(){
        for name in bgm.keys {
            self.bgm[name]?.stop()
            self.bgm[name]!.currentTime = 0
        }
    }
}