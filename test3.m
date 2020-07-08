function t=test3(m)
if m==1
    return
end
t=[];
for i=m:-1:1

    t = [t test3(m-1)];
end
end