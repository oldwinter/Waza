# Logging Techniques for Debugging

把 logs 当手术刀，不当噪音。目标是回答关于 hypothesis 的 yes/no question，而不是 dump state。

## Binary Search Instrumentation

把第一条 log 放在 execution path 的 midpoint，不放在 symptom 处。如果它正确触发，向 downstream 移动；如果没有触发，向 upstream 移动。这是在 call graph 上做 binary search。

```
Entry → [midpoint log] → ... → symptom
         ^
         第一条 log 放这里，不放 symptom 处
```

重复：每条 log 都把 remaining unknown path 砍半。

## Log What Discriminates, Not What Is Convenient

添加 log 前，写下它必须回答的问题：

> "If this prints X before Y, hypothesis A holds. If it prints Y first, A is wrong."

Discriminating log content：
- Sequence number 或 timestamp（ordering）
- Input identity key（哪个 request/item）
- Branch taken（哪个 `if` arm）
- Old vs. new state transition（不只是 new value）
- Error code 加 context string（不只是 exception message）

Never log：full request/response bodies、credentials、PII 或 huge JSON blobs。

## Log the Boundary, Not the Interior

在 behavior 应该 predictable 的 system boundaries 处 log：

- Request handler 入口/出口
- Cache read（hit or miss）with key
- State setter（old value、new value、caller）
- Async callback entry
- External API call 结果
- Build step start/end

Interior logs（tight loops 或 low-level helpers 内）通常是 noise，除非 hypothesis 专门关于该 interior。

## Prefix Discipline

使用 consistent log prefix 按 context 过滤：

```
[hunt:auth] token validate: user=42 result=expired
[hunt:cache] miss: key=user:42 latency=12ms
[hunt:render] phase=layout height=842px overflow=yes
```

当项目已有 debug flag 时，把 verbose logging gate 在其后。完成前移除 temporary logs。

## Timing Bug Logging

对 race conditions、flicker 或 intermittent failures，log：
- Event identity（哪个 event source）
- Timestamp（或 monotonic counter）
- Start and end（不只是 "it ran"）
- 涉及 concurrency 时，记录 thread/task/queue identity

如果 adding a log 改变 behavior，把它当成 timing、lifecycle 或 concurrency problem 的 evidence。不要把它 dismiss 成 "just logging side effects"。

## Removing Logs

Root cause 确认后：
1. 移除所有 temporary logs。
2. 如果某条 log 在 production 中确实有用，把它移到项目 debug flag 或 logger level 后面。
3. 除非项目本来就在 shipped code paths 中保留 debug instrumentation，否则不要留下 `console.log`、`print` 或 `fmt.Println`。
