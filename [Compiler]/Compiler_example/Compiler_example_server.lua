function onFileDecrypted()
	local decryptedData = exports.Compiler:fileDecompile("yourFile.txtc", "YourPassword")
    if decryptedData then
    	outputChatBox(decryptedData)
    	outputChatBox("Successfully decrypted yourFile.txtc")
    else
    	outputChatBox("Failed to decrypted yourFile.txtc")
    end	
end

function onResourceStartEncrypted()
	local encryptedData = exports.Compiler:fileCompile("yourFile.txt", "YourPassword")
	if encryptedData then
		local fileHandler = fileCreate("yourFile.txtc")
		fileWrite(fileHandler, encryptedData)
		fileClose(fileHandler)
        outputChatBox(encryptedData:sub(0, 256))
		outputChatBox("Successfully encrypted yourFile.txt")
		setTimer(onFileDecrypted, 5000, 1)
	else
		outputChatBox("Failed to encrypted yourFile.txt")
	end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStartEncrypted)