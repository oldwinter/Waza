# Design Reference: Data Visualization

只有当 surface 是 dashboard、analytics view、chart-heavy interface，或任何 number-dense data display 时才加载本文件。Marketing pages、landing pages 和 generic component work 不需要它。

## Dashboard defaults

Dashboards 是 utility surfaces：帮助用户定位、显示 status、支持 action。不要 hero sections，不要 marketing copy。每个 element 都必须回答用户的某个问题，才配占据位置。

- Primary layout：顶部 status summary，下方 detail；或 sidebar filters + main chart area。
- Whitespace：比 marketing pages 更紧；用户是 scan，不是 read。使用 generous column spacing，不要 generous row height。
- Number density：屏幕上同时出现很多 numbers 不是问题。没有 alignment 的 crowding 才是问题。所有 numeric columns 使用 `font-variant-numeric: tabular-nums`。Numbers right-align，labels left-align。

## Chart selection

| Use case | Chart type |
|---|---|
| Comparing values across categories | Bar chart（labels 长时用 horizontal） |
| Trend over time | Line chart；points 很多的 time series 避免用 bars |
| Part-whole relationships | Treemap（6+ segments）或 stacked bar；pie 只用于 2-4 segments |
| Distribution | Histogram 或 box plot；绝不要 pie chart |
| Correlation | Scatter plot；不要用 line chart |

超过 4 个 segments 的 pie charts 基本不传达信息。改用 treemap 或 ranked list。

## Number-dense interfaces

- 每个 number column 都使用 `font-variant-numeric: tabular-nums`，让 digits 垂直对齐。
- 所有 numbers right-align；所有 text labels left-align。同一 column 中 mixed alignment 永远不对。
- Subtle row separators：`1px` line，light 使用 `rgba(0,0,0,0.06)`，dark 使用 `rgba(255,255,255,0.05)`。只有 table 很宽（12+ columns）时才使用 alternating row backgrounds。
- Column spacing：相邻 columns 至少 `16px`；逻辑上不同的 groups 之间留更多。

## Using a product as a benchmark

当用户引用某个 product 作为 visual benchmark（"make it feel like Grafana" / "similar to Linear analytics"）时：从该 product 提取 3-5 个 concrete data-visualization-specific properties，而不是 general aesthetic properties。可用 properties：chart color palette（exact values）、grid line weight and opacity、axis label size and color、tooltip border-radius and shadow、empty-state treatment。不要提取 "minimal" 或 "clean" 作为 properties；它们不可执行。
