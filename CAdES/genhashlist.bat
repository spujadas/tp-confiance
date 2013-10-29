@echo off
for %%a in (%*) do (
od -tx1 -An "%%a" | tr -d "\n\r "
echo.|set /P=:%%a
echo.)