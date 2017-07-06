function mt = init_by_array(init_key)
%this is a Matlab implementation of the C script coded by Takuji Nishimura 
%and Makoto Matsumoto (Copyright (C) 1997 - 2002, Makoto Matsumoto and 
%Takuji Nishimura, All rights reserved. The original can be found on
%http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/CODES/mt19937ar.c

rng(19650218);
r = rng;
mt = r.State;
N= 624;
i=1;
j=0;
key_length = size(init_key,2);
k = max(N,key_length);

while(k>0)
    m = bitxor(uint64(mt(i+1)),(uint64(bitxor(mt(i) ,bitshift(mt(i),-30)))...
        * 1664525)) + init_key(j+1) + j; % non linear
    mt(i+1) = bitand(m, hex2dec('ffffffff')); % for WORDSIZE > 32 machines
    i=i+1;
    j=j+1;
    if (i>=N)
        mt(1) = mt(N);
        i=1;
    end
    if (j>=key_length)
        j=0;
    end
    k=k-1;
end
k=N-1;
while(k>0)
    m = bitxor(uint64(mt(i+1)),uint64(uint64(bitxor(mt(i) ,bitshift(mt(i),-30)))* uint64(1566083941)))  - i; % non linear
    mt(i+1) = bitand(m, hex2dec('ffffffff')); % for WORDSIZE > 32 machines
    i=i+1;
    if (i>=N)
        mt(1) = mt(N);
        i=1;
    end
    k=k-1;
end

mt(1) = bitshift(1,31); %* MSB is 1; assuring non-zero initial array
r.State = mt;
rng(r);

end
