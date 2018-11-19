#' Add one variable to the XGBoost scorecard
#' @param df a disk.frame
#' @param target a character string indicating the variable name of the target
#' @param feature a character string idnicating the variable name of the feature
#' @param monotone_constraints 1 higher value of feature equals higher success, -1 = the opposite, 0 = neither
#' @param prev_pred a vector of score equal to the nrow(df) which is the previous predictions used for hot-start
#' @param format_fn a function to transform the feature vector before fitting a model
#' @import xgboost
#' @export
add_var_to_scorecard <- function(df, target, feature, monotone_constraints = 0, prev_pred = NULL, format_fn = base::I, weight = NULL) {
  #browser()
  print(glue::glue("doing {feature}"))
  xy = df %>%
    srckeep(c(target, feature, weight)) %>%
    collect(parallel = F)
  
  # format the input if necessary
  code = glue::glue("xy = xy %>% mutate({feature} = format_fn({feature}))")
  eval(parse(text = code))
  
  not_numeric = !is.numeric(xy[1, feature, with = F][[1]])
  
  weight_name = weight
  if(!is.null(weight)) {
    weight = xy$weight
  }
  
  if(not_numeric) {
    # it must be character or factor. Now create a  default rate
    monotone_constraints = 1
    
    eval(parse(text = glue::glue("xy[, feature_s := sum({target})/.N, {feature}]")))
    dtrain <- xgboost::xgb.DMatrix(label = xy[,target, with = F][[1]], data = as.matrix(xy[,.(feature_s)]))
  } else {
    dtrain <- xgboost::xgb.DMatrix(label = xy[,target, with = F][[1]], data = as.matrix(xy[,c(feature), with = F]))
  }
  
  if(is.null(prev_pred)) {
    pt = proc.time()
    m2 <- xgboost::xgboost(
      data=dtrain, 
      nrounds = 1, 
      objective = "binary:logitraw", 
      tree_method="exact",
      monotone_constraints = monotone_constraints,
      base_score = sum(xy[,target, with = F][[1]])/nrow(xy),
      weigth = weight
    )
    timetaken(pt)
  } else {
    setinfo(dtrain, "base_margin", prev_pred)
    pt = proc.time()
    m2 <- xgboost::xgboost(
      data=dtrain, 
      nrounds = 1, 
      objective = "binary:logitraw", 
      tree_method="exact",
      monotone_constraints = monotone_constraints,
      weigth = weight
    )
    timetaken(pt)
  }
  
  # code to obtain the unique for merging
  if(not_numeric) {
    # in case where multiple categories have the same default rate
    udtrain_df = evalparseglue("xy[, .({feature} = unique({feature})), feature_s]")
    
    # keep the categories separate because xgb.DMatrix can't convert categoricals
    udtrain_df_cat = evalparseglue("udtrain_df[,.({feature})]")
    udtrain_df = udtrain_df[,.(feature_s)]
  } else {
    udtrain_df = evalparseglue("xy[, .({feature} = unique({feature}))]")
  }
  
  udtrain = xgboost::xgb.DMatrix(as.matrix(udtrain_df))
  a3 = predict(m2, udtrain, predcontrib = T) %>% data.table
  
  setnames(a3, names(a3), c("score", "bias"))
  
  stopifnot(length(unique(a3$bias)) == 1)
  bias = a3[1, bias]
  
  # summarise a4 to get the cutting points
  if(not_numeric) {
    a4 = cbind(udtrain_df, udtrain_df_cat, a3)
    a5 = a4
  } else {
    a4 = cbind(udtrain_df, a3)
    a5 = evalparseglue("a4[,.({feature} = max({feature})), score][order({feature}),]")
  }
  
  res = list(model = m2, bins = a5, prev_pred = predict(m2, dtrain), bias = bias, format_fn = format_fn, auc = auc(xy[,target, with = F][[1]], predict(m2, dtrain)), weight_name = weight_name)
  class(res) <- "xgdf_scorecard"
  res
}

#' Print 
#' @export
print.xgdf_scorecard <- function(res) {
  cat(res$model)
}