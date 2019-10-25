global robot
robot = java.awt.Robot;
base=pwd; cd 'C:\Program Files\VideoLan\VLC'
command = 'vlc "D:\NPAD\Resources\Videos\Flyover Los Angeles at Night (Raw HD 720p) [Original Full Video].avi" --noaudio --qt-fullscreen=2 --no-video-title  --start-time 300  --no-qt-fs-controller --qt-start-minimized --qt-fullscreen-screennumber=1  --no-embedded-video --fullscreen  --no-video-title-show &';
system(command); cd(base);
                   if  NFB_signal(latest_dynnr) > mean(NFB_signal(1:(latest_dynnr-1))); 
                            NF_signal=-1
                            robot.keyPress (java.awt.event.KeyEvent.VK_MINUS); %// press "enter" key6
                            robot.keyRelease (java.awt.event.KeyEvent.VK_MINUS); %// release "enter" key
                            robot.keyPress (java.awt.event.KeyEvent.VK_MINUS); %// press "enter" key6
                            robot.keyRelease (java.awt.event.KeyEvent.VK_MINUS); %// release "enter" key

                        elseif NFB_signal(latest_dynnr)< mean(NFB_signal(1:(latest_dynnr-1)));
                            NF_signal=1
                            robot.keyPress (java.awt.event.KeyEvent.VK_PLUS); %// press "enter" key
                            robot.keyRelease (java.awt.event.KeyEvent.VK_PLUS); %// release "enter" key
                            robot.keyPress (java.awt.event.KeyEvent.VK_PLUS); %// press "enter" key
                            robot.keyRelease (java.awt.event.KeyEvent.VK_PLUS); %// release "enter" key

                        else NF_signal=0
                        end
