function [p_n,v_n] = AB(p_l,p_r,v_l,v_r,d)
%AB
%    [P_N,V_N] = AB(P_L,P_R,V_L,V_R,D)

%    This function was generated by the Symbolic Math Toolbox version 6.2.
%    08-Apr-2016 10:43:33

t2 = 1.0e1.^(3.0./4.0);
t3 = 1.0./d.^(5.0./4.0);
t4 = abs(v_l);
t5 = t4.^(3.0./4.0);
t6 = abs(v_r);
t7 = t6.^(3.0./4.0);
p_n = p_l.*(1.0./2.0)+p_r.*(1.0./2.0)+v_l.*4.675e5-v_r.*4.675e5-t2.*t3.*t5.*v_l.*1.3447+t2.*t3.*t7.*v_r.*1.3447;
if nargout > 1
    v_n = p_l.*5.347593582887701e-7-p_r.*5.347593582887701e-7+v_l.*(1.0./2.0)+v_r.*(1.0./2.0)-t2.*t3.*t5.*v_l.*1.438181818181818e-6-t2.*t3.*t7.*v_r.*1.438181818181818e-6;
end