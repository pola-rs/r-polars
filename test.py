import scipy.stats as ss
#skew as previously
{
  "_F": ss.skew([1,2,3,4,5,23],nan_policy = "omit",  bias=False),
  "_T": ss.skew([1,2,3,4,5,23],nan_policy = "omit",  bias=True),
}
#skew with a missing value
{
  "_F": ss.skew([1,2,3,float("nan"),1],nan_policy = "omit", bias=False),
  "_T": ss.skew([1,2,3,float("nan"),1],nan_policy = "omit", bias=True),
  
}
#kurtosis as previous test
{
  "_TT": ss.kurtosis([1,2,3,4,5,23],nan_policy = "omit",fisher = True,  bias=True),
  "_TF": ss.kurtosis([1,2,3,4,5,23],nan_policy = "omit",fisher = True,  bias=False),
  "_FT": ss.kurtosis([1,2,3,4,5,23],nan_policy = "omit",fisher = False,  bias=True),
  "_FF": ss.kurtosis([1,2,3,4,5,23],nan_policy = "omit", fisher = False,  bias=False),
}
#kurtosis with a missing value
{
  "_TT": ss.kurtosis([1,2,3,float("nan"),1,2,3],nan_policy = "omit",fisher = True,  bias=True),
  "_TF": ss.kurtosis([1,2,3,float("nan"),1,2,3],nan_policy = "omit",fisher = True,  bias=False),
  "_FT": ss.kurtosis([1,2,3,float("nan"),1,2,3],nan_policy = "omit",fisher = False,  bias=True),
  "_FF": ss.kurtosis([1,2,3,float("nan"),1,2,3],nan_policy = "omit", fisher = False,  bias=False),
}
  