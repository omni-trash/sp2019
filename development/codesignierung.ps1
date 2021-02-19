# Code-Signierung, Ein entspr. Zertifikat sollte im Zertifikatsspeicher hinterlegt sein
$cert = Get-ChildItem Cert:\CurrentUser\My\ -CodeSigningCert
Set-AuthenticodeSignature "C:\Pfad\zur\Datei" $cert -TimeStampServer "http://timestamp.globalsign.com/scripts/timstamp.dll"

# Variante2
$cert = Get-ChildItem Cert:\CurrentUser\My\ -CodeSigningCert
$file = "C:\path\to\your\file"
Set-AuthenticodeSignature $file $cert -TimeStampServer "http://timestamp.digicert.com" -HashAlgorithm SHA256
