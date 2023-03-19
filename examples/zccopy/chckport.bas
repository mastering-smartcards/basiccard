Sub CheckPort()
	CardReader
	if (SW1SW2 = swNoCardReader) then
		ComPort=2
		CardReader
		if (SW1SW2 = swNoCardReader) then
			REM PCSC
			ComPort=100
		end if
	end if
End Sub