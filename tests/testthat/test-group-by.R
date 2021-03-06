context("test-group_by")

setup({
  
  df = disk.frame:::gen_datatable_synthetic(1e3+11)
  data.table::fwrite(df, file.path(tempdir(), "tmp_pls_delete_gb.csv"))
})

test_that("group_by", {
  dff = csv_to_disk.frame(
    file.path(tempdir(), "tmp_pls_delete_gb.csv"), 
    file.path(tempdir(), "tmp_pls_delete_gb.df"))
  dff_res = dff %>% 
    collect %>% 
    group_by(id1) %>% 
    summarise(mv1 = mean(v1))
  
  expect_warning({
    dff %>% 
    group_by(id1, id2) %>%
    summarise(mv1 = mean(v1)) %>% 
    collect
  })
  
  dff1 <- dff %>% 
    chunk_group_by(id1, id2) %>%
    chunk_summarise(mv1 = mean(v1)) %>% 
    collect

  
  expect_false(nrow(dff1) == nrow(dff_res))
})

test_that("test hard_group_by on disk.frame", {
  dff = csv_to_disk.frame(
    file.path(tempdir(), "tmp_pls_delete_gb.csv"), 
    file.path(tempdir(), "tmp_pls_delete_gb.df"))
  dff_res = dff %>% 
    collect %>% 
    group_by(id1, id2) %>% 
    summarise(mv1 = mean(v1))
  
  dff1 <- dff %>% 
      hard_group_by(id1, id2) %>%
      chunk_summarise(mv1 = mean(v1)) %>% collect
  
  expect_equal(nrow(dff1), nrow(dff_res))
})

test_that("test hard_group_by on data.frame", {
  df = disk.frame:::gen_datatable_synthetic(1e3+11)
  
  df1 = df %>% 
    group_by(id1, id2) %>% 
    summarise(mv1 = mean(v1))
  
  dff1 <- df %>% 
    hard_group_by(id1,id2) %>%
    summarise(mv1 = mean(v1))
  
  expect_equal(nrow(dff1), nrow(df1))
})


test_that("test hard_group_by on disk.frame (sort)", {
  dff = csv_to_disk.frame(
    file.path(tempdir(), "tmp_pls_delete_gb.csv"), 
    file.path(tempdir(), "tmp_pls_delete_gb.df"))
  dff_res = dff %>% 
    collect %>% 
    group_by(id1, id2) %>% 
    summarise(mv1 = mean(v1))
  
  dff1 <- dff %>% 
    hard_group_by(id1, id2, shardby_function="sort") %>%
    chunk_summarise(mv1 = mean(v1)) %>% collect
  
  expect_equal(nrow(dff1), nrow(dff_res))
})

test_that("test hard_group_by on data.frame (sort)", {
  df = disk.frame:::gen_datatable_synthetic(1e3+11)
  
  df1 = df %>% 
    group_by(id1, id2) %>% 
    summarise(mv1 = mean(v1))
  
  dff1 <- df %>% 
    hard_group_by(id1, id2, shardby_function="sort") %>%
    summarise(mv1 = mean(v1))
  
  expect_equal(nrow(dff1), nrow(df1))
})


teardown({
  fs::file_delete(file.path(tempdir(), "tmp_pls_delete_gb.csv"))
  fs::dir_delete(file.path(tempdir(), "tmp_pls_delete_gb.df"))
})
