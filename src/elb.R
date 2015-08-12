require("ggplot2")
require("gridExtra")
library(scales)

df = read.table("elb.log")
df$date=as.POSIXct(df$V1, format="%Y-%m-%dT%H:%M:%S")
df$incoming = df$V5 * 1000
df$backend = df$V6 * 1000
df$out = df$V7 * 1000
df$URL = df$V12

top_3_urls <- head(names(sort(table(df$URL),decreasing=TRUE)),3)

df_filter <- df
df_rest <- df[!df$URL %in% top_3_urls,]

p1 <- ggplot(df_filter, aes(x = df_filter$backend)) +
  stat_ecdf() +
  scale_x_log10(name="ms", limit = c(3,50), breaks = c(seq(1,10),seq(20,100,10))) +
  scale_y_continuous(labels = percent, breaks = c(0,0.5,0.9,0.95,0.99,1), minor_breaks=seq(0,1,0.1), name="Percentiles")

p2 <- ggplot(df_filter, aes(x=df_filter$URL, fill=df_filter$URL)) +
  geom_histogram() +
  scale_y_continuous(name = "Total Requests", labels = comma) +
  scale_x_discrete(name = "URL") +
  guides(fill = FALSE)

p3 <- ggplot(df_filter, aes(x=df_filter$date, fill=df_filter$URL)) +
  stat_bin(binwidth=60) +
  scale_x_datetime(name = "Time") +
  scale_y_continuous(name = "Requests/minute") +
  guides(fill = FALSE)

p4 <- ggplot(df_filter, aes(x = df_filter$date, y = df_filter$backend)) +
  stat_bin2d(bins=200) +
  scale_x_datetime(name = "Time") +
  scale_y_log10(name = "s", limits = c(0.001,1)) +
  scale_fill_gradient(low="#00bae5", high="#fa5c19", name="Request count") +
  theme(legend.position = "bottom")

svg("elb.svg", width=10, height=10)
grid.arrange(arrangeGrob(p1, p2, ncol=2), p3, p4, ncol = 1)
dev.off()
