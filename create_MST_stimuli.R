# Creating MST stimuli

library(readxl)
library(dplyr)
library(stringr)

# Load original MST file
df <- read_excel("Sets1_6_Rankings_Named.xlsx")

# Filter rows where Set Assignment is 1 and 2
df <- df %>%
  filter(`Set Assignment` == 1) %>%
  select(`Set Assignment`, `Stim #`, `Lure Bin`)


colnames(df) <- c("set", "stim", "lure_bin")
# df: 192 x 3, columns: set, stim, lure_bin



df <- df %>%
  mutate(stim = str_remove(stim, "b\\.jpg$"))

df <- df %>%
  mutate(stim = str_remove(stim, "a\\.jpg$"))

#df <- df %>%
#  select(-set)


# df: 192 x 3, columns: set, stim, lure_bin

# 1) desired counts per lure_bin for each condition
target_old <- c(`2` = 16, `3` = 16, `4` = 16, `5` = 16)

# sanity check (not required to run, just for logic)
# colSums(rbind(target_old1, target_old2, target_new1))
# should give: 39, 38, 39, 38, 38

# 2) helper function: sample by lure_bin according to a target vector
library(dplyr)

# Work from df with columns: set, stim, lure_bin
# (and you already removed a/b suffixes etc.)

# --- helper (unchanged) ---
sample_by_bin <- function(dat, target_vec, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  dat %>%
    group_by(lure_bin) %>%
    group_split() %>%
    lapply(function(g) {
      bin <- as.character(g$lure_bin[1])
      n_here <- target_vec[bin]
      slice_sample(g, n = n_here)
    }) %>%
    bind_rows() %>%
    ungroup()
}

# --- sample old_1 and old_2 ONLY from bins 2:5 ---
df_25 <- df %>% filter(lure_bin %in% 2:5)

target_old <- c(`2` = 16, `3` = 16, `4` = 16, `5` = 16)

df_old1 <- sample_by_bin(df_25, target_old, seed = 1) %>%
  mutate(cond = "old_1")

df_rem1 <- anti_join(df, df_old1, by = c("set", "stim", "lure_bin"))

df_25_rem1 <- df_rem1 %>% filter(lure_bin %in% 2:5)

df_old2 <- sample_by_bin(df_25_rem1, target_old, seed = 2) %>%
  mutate(cond = "old_2")

df_rem2 <- anti_join(df_rem1, df_old2, by = c("set", "stim", "lure_bin"))

# --- build new_1: all remaining bin1 + fill from remaining others ---
bin1_pool  <- df_rem2 %>% filter(lure_bin == 1)
other_pool <- df_rem2 %>% filter(lure_bin != 1)

n_need <- 64 - nrow(bin1_pool)
if (n_need < 0) stop("More than 64 items in lure_bin==1 left; cannot include them all in new_1.")
if (nrow(other_pool) < n_need) stop("Not enough remaining items to fill new_1 to 64.")

set.seed(3)
df_new1 <- bind_rows(
  bin1_pool,
  other_pool %>% slice_sample(n = n_need)
) %>%
  mutate(cond = "new_1", lure_bin = 0)

# --- combine (NO left_join back to df; you want only the selected trials) ---
df_cond <- bind_rows(df_old1, df_old2, df_new1)

# checks
table(df_cond$cond)
table(df_cond$cond, df_cond$lure_bin)


# Create the new simtuli for the second test session (64 random from set 2)

set.seed(42)  # for reproducibility

# 1. Create 64 random stim numbers between 001 and 192
new_rows <- tibble(
  set = 2,
  stim = sprintf("%03d", sample(1:192, 64, replace = FALSE)),  # zero-padded 3-digit numbers
  lure_bin = 0,
  cond = "new_2"
)

# 2. Add them to your existing df_cond
df_final <- bind_rows(df_cond, new_rows)

# 3. Check
nrow(df_final)         # should be 256 (192 + 64)
table(df_final$cond)

# change lure bins of new to 0
df_final <- df_final %>%
  mutate(lure_bin = if_else(cond == "new_1", 0, lure_bin))

# check
table(df_final$cond)
# existing 256-row df_final with cond = old_1, old_2, new_1, new_2

# Create similar conditions


# 1. create similar_1 from old_2
df_sim1 <- df_final %>%
  filter(cond == "old_2") %>%
  mutate(cond = "similar_1",
         lure_bin = lure_bin)  # keep same bin (or modify later if needed)

# 2. create similar_2 from old_1
df_sim2 <- df_final %>%
  filter(cond == "old_1") %>%
  mutate(cond = "similar_2",
         lure_bin = lure_bin)

# 3. combine everything
df_full <- bind_rows(df_final, df_sim1, df_sim2)

# 4. quick check
table(df_full$cond)

# add 
df_full <- df_full %>%
  mutate(
    stim = if_else(
      cond %in% c("similar_1", "similar_2"),
      paste0(stim, "b.jpg"),   # e.g. 011 → 011a.jpg
      paste0(stim, "a.jpg")    # e.g. 011 → 011b.jpg
    )
  )

# Save
write_xlsx(df_full, "MST_stimuli_lurebins2345.xlsx", row.names = FALSE)
