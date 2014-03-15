function u_closest = decode6( y, G, U_min, U_max )
%DECODE6( y, G ) Lattice Decode
%   u_closest = DECODE6( y, G ) returns the indexes of the closest
%   lattice vector for a given lower triangular generator matrix G
%   and any row vector y.
%   (Algorithm 6 by A. Ghasemmehdi, E. Agrell)

% A. Ghasemmehdi, E. Agrell, "Faster Recursions in Sphere Decoding,"
% IEEE Trans. Inf. Theory, vol. 57, no. 6, pp. 3530-3536, June 2011.

validateInput(G,y,U_min,U_max);
n=size(G,1);

%= Declaration =%
dist=zeros(1,n+1);
u=zeros(1,n);
F=zeros(n,n);
p=zeros(1,n);
step=zeros(1,n);
u_closest=zeros(1,n);

%= Initialization =%
rho_n=Inf;
k=n+1;
d=zeros(1,n)+n;
dist(n+1)=0;
F(n,1:n)=y(1:n);
loop_down=true;

while(true) %LOOP_LABEL
    
    while(loop_down)
        if(~(k==1))
            k=k-1;
            for a=d(k):-1:(k+1)
                F(a-1,k)=F(a,k)-u(a)*G(a,k);
            end
            p(k)=F(k,k)/G(k,k);
            u(k)=roundc(p(k),U_min,U_max);
            gamma=(p(k)-u(k))*G(k,k);
            step(k)=sgn(gamma);
            dist(k)=dist(k+1)+gamma^2;            
        else
            u_closest=u;
            rho_n=dist(1);
        end
        loop_down=(dist(k)<rho_n);
    end
    m=k;
    while(~loop_down)
        if (k==n)
            return;
        else
            k=k+1;
            gamma=Inf;
            u(k)=u(k)+step(k);
            step(k)=-step(k)-sgn(step(k));
            if ( (U_min<=u(k)) && (u(k)<=U_max))
                gamma=(p(k)-u(k))*G(k,k);
            else
                u(k)=u(k)+step(k);
                step(k)=-step(k)-sgn(step(k));
                if ( (U_min<=u(k)) && (u(k)<=U_max))
                    gamma=(p(k)-u(k))*G(k,k);
                end
            end
            dist(k)=dist(k+1)+gamma^2;
        end
        loop_down=(dist(k)<rho_n);
    end

    d(m:k-1)=k;
    for a=(m-1):-1:1
        if (d(a)<k)
            d(a)=k;
        else
            break;
        end
    end
    
end % GOTO LOOP_LABEL
