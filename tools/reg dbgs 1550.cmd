rem @echo off
set Port=1550
set appver=8.3.10.2699
set SrvcName="1C:Enterprise 8.3 Remote Debug Server"
set BinPath="\"C:\Program Files\1cv8\%appver%\bin\dbgs.exe\" --service --addr=10.0.75.1 --port=%Port%"
set Desctiption="1C Remote Debug Server"
sc stop %SrvcName%
sc delete %SrvcName%
sc create %SrvcName% binPath= %BinPath% start= auto displayname= %Desctiption%