function loadBanshee()
	local txd = exports.Compiler:fileDecompile("banshee.compileTxd", "YourPassword")
	local dff = exports.Compiler:fileDecompile("banshee.compileDff", "YourPassword")
	if txd and dff then
		local loadTXD = engineLoadTXD(txd)
		engineImportTXD(loadTXD, 429)
		local loadDFF = engineLoadDFF(dff)
		engineReplaceModel(loadDFF, 429)
		outputChatBox("Successfully decrypted model banshee and loaded")
	else
		outputChatBox("Failed to decrypted model banshee")
	end
end

function onClientResourceStart()
	local isEncryptedTxd = exports.Compiler:replaceCompileFile("banshee.txd", "YourPassword", "banshee.compileTxd")
	local isEncryptedDff = exports.Compiler:replaceCompileFile("banshee.dff", "YourPassword", "banshee.compileDff")
	if isEncryptedTxd and isEncryptedDff then
		setTimer(loadBanshee, 5000, 1)
		outputChatBox("Successfully encrypted banshee model files")
	else
		outputChatBox("Failed to encrypted model banshee")
	end
end
addEventHandler( "onClientResourceStart", resourceRoot, onClientResourceStart)