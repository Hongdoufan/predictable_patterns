tren=addfile("/disk1/fhd/winter_forecast/data/eof_t2m_obs_eof2.nc","r")
pc2=tren->eof_ts
bbb1=pc2(0:34)
bbb2=pc2(1:35)
c=regCoef(bbb1,bbb2)
forecast=pc2(35)*c+c@yintercept
print(forecast)
