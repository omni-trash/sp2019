# Code-Signierung, Ein entspr. Zertifikat sollte im Zertifikatsspeicher hinterlegt sein
cd \temp
$cert = Get-ChildItem Cert:\CurrentUser\My\ -CodeSigningCert
Set-AuthenticodeSignature "C:\Pfad\zur\Datei" $cert -TimeStampServer "http://timestamp.globalsign.com/scripts/timstamp.dll"
