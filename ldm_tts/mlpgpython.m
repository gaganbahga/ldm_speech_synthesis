function C = mlpgpython(Y,U)

Y = Y(:)';
U = U(:)';
m = 40;
if count(py.sys.path,'') == 0
    insert(py.sys.path,int32(0),'');
end

Y = py.numpy.asarray(single(Y));
Y = Y.reshape(int32([-1,3*m]));
U = py.numpy.asarray(single(U));
U = U.reshape(int32([-1,3*m]));

dim = py.numpy.asarray(int32(m));
mlpgObj = py.mlpg_fast.MLParameterGenerationFast;   % uses python function which uses numpy, bandmat
C = mlpgObj.generation(Y,U,dim);

C = double(py.array.array('d',py.numpy.nditer(C))); %d is for double
C = reshape(C,m, []);

end