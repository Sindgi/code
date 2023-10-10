import dropbox

access_token='sl.A-OlRPvUr8DxfPar5rXmAsPVL-RIPA8iAQoZUKN1NNqAyZigijQYhMH3iO3tIkH8ew9lAVSMZPbiJMYqP1sxhJ8RlpwElYaINXO_b9t0G0QyO-bQmt1KFPHwfTlaRFsj7m8d1fU';


dbx = dropbox.Dropbox(access_token)
f = open("encoded.bin","w")                    
metadata,res = dbx.files_download("encoded.bin")     //dropbox file path
f.write(res.content)
