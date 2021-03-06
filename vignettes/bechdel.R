## ---- message=FALSE, warning=FALSE---------------------------------------
library(dplyr)
library(ggplot2)
library(knitr)
library(magrittr)
library(broom)
library(stringr)
library(fivethirtyeight)
library(ggthemes)
library(scales)
data("bechdel")
# Turn off scientific notation
options(scipen = 99)

## ----bechdel90_13--------------------------------------------------------
bechdel90_13 <- bechdel %>% filter(between(year, 1990, 2013))

## ----mutate--------------------------------------------------------------
bechdel90_13 %<>% 
  mutate(int_only = intgross_2013 - domgross_2013,
         roi_total = intgross_2013 / budget_2013,
         roi_dom = domgross_2013 / budget_2013,
         roi_int = int_only / budget_2013)

## ----generous------------------------------------------------------------
bechdel90_13 %<>%
  mutate(generous = ifelse(test = clean_test %in% c("ok", "dubious"),
                           yes = TRUE,
                           no = FALSE))

## ----summary_ROI---------------------------------------------------------
ROI_by_binary <- bechdel90_13 %>% 
  group_by(binary) %>% 
  summarize(median_ROI = median(roi_total, na.rm = TRUE))
ROI_by_binary
bechdel90_13 %>% 
  summarize(
    `Median Overall Return on Investment` = median(roi_total, na.rm = TRUE))

## ----summary_budget------------------------------------------------------
budget_by_binary <- bechdel90_13 %>% 
  group_by(binary) %>% 
  summarize(median_budget = median(budget_2013, na.rm = TRUE))
budget_by_binary
bechdel90_13 %>% 
  summarize(`Median Overall Budget` = median(budget_2013, na.rm = TRUE))

## ----budget-plot, fig.width = 5, warning = FALSE-------------------------
ggplot(data = bechdel90_13, mapping = aes(x = budget)) +
  geom_histogram(color = "white", bins = 20) +
  labs(title = "Histogram of budget")

## ----log-budget-plot, fig.width = 5, warning = FALSE---------------------
ggplot(data = bechdel90_13, mapping = aes(x = log(budget))) +
  geom_histogram(color = "white", bins = 20) +
  labs(title = "Histogram of Logarithm of Budget")

## ----intgross-plot, fig.width = 5, warning = FALSE-----------------------
ggplot(data = bechdel90_13, mapping = aes(x = intgross_2013)) +
  geom_histogram(color = "white", bins = 20) +
  labs(title = "Histogram of International Gross")

## ----log-intgross-plot, fig.width = 5, warning = FALSE-------------------
ggplot(data = bechdel90_13, mapping = aes(x = log(intgross_2013))) +
  geom_histogram(color = "white", bins = 20) +
  labs(title = "Histogram of Logarithm of International Gross")

## ----roi-plot, fig.width = 5, warning = FALSE----------------------------
ggplot(data = bechdel90_13, mapping = aes(x = roi_total)) +
  geom_histogram(color = "white", bins = 20) +
  labs(title = "Histogram of ROI")

## ----log-roi-plot, fig.width = 5, warning = FALSE------------------------
ggplot(data = bechdel90_13, mapping = aes(x = log(roi_total))) +
  geom_histogram(color = "white", bins = 20) +
  labs(title = "Histogram of Logarithm of ROI")

## ----scatplot1, fig.width = 5, warning=FALSE-----------------------------
ggplot(data = bechdel90_13, 
       mapping = aes(x = log(budget_2013), y = log(intgross_2013))) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

## ----reg1----------------------------------------------------------------
gross_vs_budget <- lm(log(intgross_2013) ~ log(budget_2013), 
                      data = bechdel90_13)
tidy(gross_vs_budget)

## ----scatplot2, fig.width = 5, warning=FALSE-----------------------------
ggplot(data = bechdel90_13, 
       mapping = aes(x = log(budget_2013), y = log(intgross_2013), 
                     color = binary)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

## ----reg2----------------------------------------------------------------
gross_vs_budget_binary <- lm(log(intgross_2013) ~ log(budget_2013) + factor(binary), 
                      data = bechdel90_13)
tidy(gross_vs_budget_binary)

## ----scatplot3, warning=FALSE--------------------------------------------
ggplot(data = bechdel90_13, 
       mapping = aes(x = log(budget_2013), y = log(roi_total))) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

## ----reg3----------------------------------------------------------------
roi_vs_budget <- lm(log(roi_total) ~ log(budget_2013), 
                      data = bechdel90_13)
tidy(roi_vs_budget)

## ----scatplot4, warning=FALSE--------------------------------------------
ggplot(data = bechdel90_13, 
       mapping = aes(x = log(budget_2013), y = log(roi_total), 
                     color = binary)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

## ----reg4----------------------------------------------------------------
roi_vs_budget_binary <- lm(log(roi_total) ~ log(budget_2013) + factor(binary), 
                      data = bechdel90_13)
tidy(roi_vs_budget_binary)

## ----roi-graphic---------------------------------------------------------
passes_bechtel_rom <- bechdel90_13 %>% 
  filter(generous == TRUE) %>% 
  summarize(median_roi = median(roi_dom, na.rm = TRUE))
median_groups_dom <- bechdel90_13 %>% 
  filter(clean_test %in% c("men", "notalk", "nowomen")) %>% 
  group_by(clean_test) %>% 
  summarize(median_roi = median(roi_dom, na.rm = TRUE))
pass_bech_rom <- data_frame(clean_test = "pass", 
                  median_roi = passes_bechtel_rom$median_roi)
med_groups_dom_full <- bind_rows(pass_bech_rom, median_groups_dom) %>% 
  mutate(group = "U.S. and Canada")

## ----roi-graphic2, fig.width=5-------------------------------------------
passes_bechtel_int <- bechdel90_13 %>% 
  filter(generous == TRUE) %>% 
  summarize(median_roi = median(roi_int, na.rm = TRUE))
median_groups_int <- bechdel90_13 %>% 
  filter(clean_test %in% c("men", "notalk", "nowomen")) %>% 
  group_by(clean_test) %>% 
  summarize(median_roi = median(roi_int, na.rm = TRUE))
pass_bech_int <- data_frame(clean_test = "pass", 
                  median_roi = passes_bechtel_int$median_roi)
med_groups_int_full <- bind_rows(pass_bech_int, median_groups_int) %>% 
  mutate(group = "International")
med_groups <- bind_rows(med_groups_dom_full, med_groups_int_full) %>% 
  mutate(clean_test = str_replace_all(clean_test, 
                                      "pass",
                                      "Passes Bechdel Test"),
         clean_test = str_replace_all(clean_test, "men",
                                      "Women only talk about men"),
         clean_test = str_replace_all(clean_test, "notalk",
                                      "Women don't talk to each other"),
         clean_test = str_replace_all(clean_test, "nowoWomen only talk about men",
                                      "Fewer than two women"))
med_groups %<>% mutate(clean_test = factor(clean_test, 
                                 levels = c("Fewer than two women", 
                                            "Women don't talk to each other",
                                            "Women only talk about men",
                                            "Passes Bechdel Test"))) %>% 
  mutate(group = factor(group, levels = c("U.S. and Canada", "International"))) %>% 
  mutate(median_roi_dol = dollar(median_roi))

## ----basic-538, fig.width=8----------------------------------------------
ggplot(data = med_groups, mapping = aes(x = clean_test, y = median_roi, 
                                        fill = group)) +
  geom_bar(stat = "identity") +
  facet_wrap(~ group) +
  coord_flip() +
  labs(title = "Dollars Earned for Every Dollar Spent", subtitle = "2013 dollars") +
  scale_fill_fivethirtyeight() +
  theme_fivethirtyeight()

## ----roi-plot-538, fig.width=8-------------------------------------------
ggplot(data = med_groups, mapping = aes(x = clean_test, y = median_roi, 
                                        fill = group)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = median_roi_dol), hjust = -0.1) +
  scale_y_continuous(expand = c(.25, 0)) +
  coord_flip() +
  facet_wrap(~ group) +
  scale_fill_manual(values = c("royalblue", "goldenrod")) +
  labs(title = "Dollars Earned for Every Dollar Spent", subtitle = "2013 dollars") +
  theme_fivethirtyeight() +
  theme(plot.title = element_text(hjust = -1.6), 
        plot.subtitle = element_text(hjust = -0.4),
        strip.text.x = element_text(face = "bold", size = 16),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank()) +
  guides(fill = FALSE)

