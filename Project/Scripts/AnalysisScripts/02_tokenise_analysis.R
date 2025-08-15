#!/usr/bin/env Rscript
# ---------------------------------------------------------------
# 02_tokenise_analysis.R full tidy-text workflow
library(dplyr); library(tidyr); library(tidytext)
library(ggplot2); library(tokenizers); library(widyr)
library(scales); library(viridis); library(tibble)
library(stringr); library(readr) # for write_rds()

  # 1. Load raw text
  # ------------------------------------------------------------------
raw <- readLines("Project/Data/InputData/revenge_sith_raw.txt")
# ------------------------------------------------------------------
# 2. Split into speaker / dialogue
# ------------------------------------------------------------------
lines <- strsplit(raw, "\n")[[1]]
ep3 <- tibble(text = raw) %>%
  separate(text, c("speaker","dialogue"),
           sep = ":", extra = "merge", fill = "right") %>%
  mutate(across(everything(), str_trim)) %>%
  filter(dialogue != "") %>% # keep spoken lines only
  mutate(line_id = row_number())
# Save a clean RDS copy
write_rds(ep3, "Project/Data/AnalysisData/ep3_clean.rds")

#Word tokens + stop-word removal
# ------------------------------------------------------------------
data("stop_words", package = "tidytext")
ep3_words <- unnest_tokens(ep3, word, dialogue, token = "words")
ep3_nostop <- anti_join(ep3_words, stop_words, by = "word")
write_rds(ep3_nostop, "Project/Data/AnalysisData/ep3_nostop.rds")

#Top 15 clean bigrams
# ------------------------------------------------------------------
top_bigrams <- ep3 %>%
  unnest_tokens(bigram, dialogue, token = "ngrams", n = 2) %>%
  separate(bigram, c("w1","w2"), " ", remove = FALSE) %>%
  filter(!w1 %in% stop_words$word, !w2 %in% stop_words$word) %>%
  count(bigram, sort = TRUE) %>%
  slice_max(n, n = 15)
# --- Plot
ggplot(top_bigrams, aes(reorder(bigram, n), n)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(labels = comma) +
  labs(title = "Top 15 clean bigrams",
       x = NULL, y = "Frequency") +
  theme_minimal()
library(dplyr)
library(tidytext)

# 1. Retokenize so we still have the full dialogue in each row
contexts <- ep3 |>
  # keep only lines containing the bigram "sith lord"
  filter(str_detect(dialogue, regex("\\bsith lord\\b", ignore_case = TRUE))) |>
  select(line_id, speaker, dialogue)
# 2. View a sample of those lines
contexts
library(tidytext)
library(ggplot2)
bigram_timeline <- ep3 |>
  unnest_tokens(bigram, dialogue, token = "ngrams", n = 2) |>
  filter(bigram == "sith lord") |>
  count(line_id) # how many mentions per line
ggplot(bigram_timeline, aes(x = line_id, y = n)) +
  geom_col() +
  labs(
    x = "Script Line Number",
    y = "Mentions of sith lord",
    title = "When sith lord Peaks in the Narrative"
  )
ggsave("Project/Output/Results/top_clean_bigrams.png", width = 6, height = 4)

#TF-IDF: top 5 words per top-5 speakers
top_speakers <- ep3 %>%
  count(speaker, sort = TRUE) %>%
  slice_max(order_by = n, n = 5) %>%
  pull(speaker)

tfidf <- ep3_nostop %>%
  filter(speaker %in% top_speakers) %>%
  count(speaker, word, sort = TRUE) %>%
  bind_tf_idf(word, speaker, n) %>%
  group_by(speaker) %>%
  slice_max(order_by = tf_idf, n = 5) %>%
  ungroup()
ggplot(tfidf, aes(speaker, word, fill = tf_idf)) +
  geom_tile(color = "white") +
  scale_fill_viridis_c(option = "C") +
  labs(title = "Top 5 TFIDF terms per speaker",
       x = "Speaker", y = NULL, fill = "TFIDF") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave("Project/Output/Results/tfidf_heatmap.png", width = 7, height = 5)

# ------------------------------------------------------------------
# 6. PMI Collocations ( 5 co-occurrences)
# ------------------------------------------------------------------
pair_counts <- pairwise_count(ep3_nostop, word, line_id, sort = TRUE)
pair_pmi <- pairwise_pmi(ep3_nostop, word, line_id)
pmi_top15 <- inner_join(pair_pmi, pair_counts,
                        by = c("item1","item2")) %>%
  filter(n >= 5) %>%
  slice_max(order_by = pmi, n = 15)
ggplot(pmi_top15,
       aes(reorder_within(item1, pmi, item2), pmi)) +
  geom_col() +
  facet_wrap(~ item2, scales = "free_y") +
  coord_flip() +
  scale_x_reordered() +
  labs(title = "Top 15 PMI collocations (n 5)",
       x = "Word 1", y = "PMI") +
  theme_minimal()
ggsave("Project/Output/Results/pmi_collocations.png",
       width = 8, height = 6)


