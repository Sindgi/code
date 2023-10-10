import dropbox

dropbox_access_token='sl.A-OlRPvUr8DxfPar5rXmAsPVL-RIPA8iAQoZUKN1NNqAyZigijQYhMH3iO3tIkH8ew9lAVSMZPbiJMYqP1sxhJ8RlpwElYaINXO_b9t0G0QyO-bQmt1KFPHwfTlaRFsj7m8d1fU';

dropbox_path= "/mytest/encoded.bin"
computer_path="encoded.bin"

client = dropbox.Dropbox(dropbox_access_token)
print("[SUCCESS] dropbox account linked")

client.files_upload(open(computer_path, "rb").read(),dropbox_path)
print("[UPLOADED] {}".format(computer_path))
