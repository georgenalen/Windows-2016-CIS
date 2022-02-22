＜powershell＞
  import-Module AWSPowershell
  $SecretAD = "WINDOWS_PW"
  $SecretObj = (Get-SECSecretValue -SecretId $SecretAD)
  $Secret = ($SecretObj.SecretString  | ConvertFrom-Json)
  $password   = $Secret.Password | ConvertTo-SecureString -asPlainText -Force

  $UserAccount = Get-LocalUser -Name "administrator"
  $UserAccount | Set-LocalUser -Password $Password

  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
  [Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"
  Invoke-WebRequest -Uri https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1 -OutFile ConfigureRemotingForAnsible.ps1
  powershell -ExecutionPolicy RemoteSigned .\ConfigureRemotingForAnsible.ps1

＜/powershell＞
