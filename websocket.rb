require 'em-websocket'
require 'json'

def emulator_control_pannel(command)
	sdk_root="/home/ubuntu/android-sdk-linux/platform-tools/"
	command_JSON = JSON.parse(command)
	device = command_JSON["device"]
	puts(command_JSON['action'])
	if(command_JSON['action'] == "click")
		parameters = command_JSON['x'] +" "+command_JSON['y']
		runC  = sdk_root+"adb -s "+device+" shell input tap "+parameters
		system(runC)
	end

	if (command_JSON['action'] == 'swipe')
		parameters = command_JSON["xi"] +" "+command_JSON["yi"]
		parameters = parameters + " " + command_JSON["xf"] + " " +command_JSON["yf"]
		command  = sdk_root+"adb -s "+device+" shell input swipe "+parameters
		system(command)
	end

	if(command_JSON['action'] == 'back')
		command  = sdk_root+"adb -s "+device+" shell input keyevent 4"
      	system(command)
	end

	if(command_JSON['action'] == 'unlock')
		command = sdk_root+"adb -s "+device+" shell input keyevent 82"
		system(command)
	end

	if(command_JSON["action"] == "install")
		t1 = Time.now
		url = "wget '"+ command_JSON["url"] + "' -O "+  sdk_root+"temp"+device+".apk "
		system(url)
		install_apk =   "cd "+sdk_root+" && ./adb -s "+device+" install temp"+device+".apk "
		#puts(install_apk)
    	system(install_apk)

   		class_name = command_JSON["class_name"]
    	package_name = command_JSON["package_name"]
    	launch_app = "cd "+sdk_root+" && ./adb -s "+device+" shell am start -a android.intent.action.MAIN " + package_name + "/." + class_name
    	system(launch_app)
    	t2 = Time.now
    	puts("____________TotalTime_____________")
    	puts(time_diff_milli(t1,t2))
    	puts("___________________________________")
	end

end

def time_diff_milli(start, finish)
   (finish - start) * 1000.0
end


EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 5900) do |ws|
  ws.onopen    { ws.send "we are connect"}
  ws.onmessage do |msg|
  	begin
  		emulator_control_pannel(msg)	
  	rescue Exception => e
  		puts(e)
  	end
  	
  	ws.send "Pong: #{msg}" 
  end
  ws.onclose   { puts "WebSocket closed" }
end