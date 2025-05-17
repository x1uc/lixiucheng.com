---
srcTitle: Why Good Developers Write Bad Unit Tests
srcDate: "2018-11-09"
srcLink: "https://mtlynch.io/good-developers-bad-tests/"
srcAuthor: "Michael Lynch"

title: "优秀的开发者不一定会写优秀的单元测试"
description: 如果不根据单元测试的特点进行调整，常见的优秀开发技术反而可能误导你。
tags:
  - testing
date: "2025-05-16"
images:
  - good-developers-bad-tests/cover.jpg
---

恭喜，你通过多年写下的百万行代码终于可以拿下一栋海景别墅。你雇佣了世界上最顶尖的摩天大楼建筑师来为你打造它，他保证他的建筑方案会让你满意。

几个月过去了，你来到了盛大的揭幕仪式。你的别墅是一栋由钢筋、混凝土、反光玻璃组成的五层巨兽。当你穿过旋转门时，沙子被带到了豪华的大理石地板上。接下来映入眼帘的是一个接待台，后面是一排电梯。让我们看下楼上，你的主卧和三间客房。只不过看起来像是办公室改造的。

{{<img src="cover.jpg" alt="Architect presenting skyscraper on the beach" max-width="800px">}}

这位杰出的建筑师不明白你为何会感觉到如此失望。"我可是遵循了所有的 _最佳实践!_"。因为结构稳固至关重要，所以你家的墙有足足3英尺厚。因此，从理论上来说，你的房子是比邻居好的，你完全没必要羡慕邻居通风优秀、采光良好的房子。你家没有大大的海景窗，因为这位建筑师坚信那种窗户 _不符合最佳实践_——它们降低能效，还会分散办公室员工的注意力。

软件开发者常常将这种错误的思维带入到`unit testing`中。他们机械的认为在生产代码中学到的规则可以应用在任何场景。他们没有考虑过这些规则在测试场景中是否恰当。最终导致的结果就是，他们在沙滩边建了一栋摩天大楼。

## 测试代码的特殊性

生产环境的代码规模庞大，通常包含几千~几百万行代码。面对这种体量的代码，没有人可以一下就理解。为了应对这种复杂性，编程语言设计者引入了函数、类层级等机制，帮助开发者通过抽象来思考问题。

好的生产代码努力的实现封装。这让开发者可以自由的在代码中进行穿梭。可以深入细节，也可以上升到更高的抽象层级。

测试代码的评定维度和生产代码不一致。一个优秀的单元测试常常是很小的，它的内容让人一目了然。对单元测试添加抽象层是增加它的复杂性。测试是诊断工具，他们应该简单并且足够直观。

{{<notice type="info">}}
**生产代码的核心在于良好的结构(well-factored)；测试代码的核心在于 _直观_.**
{{</notice>}}

{{<img src="dane-deaner-272363-unsplash-cropped.jpg" alt="Image of a ruler" max-width="325px" align="right" href="https://unsplash.com/photos/JNpmCYZID68">}}

我们讨论一下尺子这种工具。它之所以能存在数百年，就是因为它不复杂，使用简单。假如我制作了一把"德古拉尺"，它的单位是"德古拉"，"德古拉"与厘米有一定的转换关系。你需要使用一张换算表去进行换算。

假如我把"德古拉尺"提供给木匠，他一定狠狠的抽我一巴掌。为一个非常直观的工具添加一个抽象层是无比滑稽的。

好的测试代码也是一样。它应该让人一目了然，而不是为了理解它需要让读者跳入到一个间接的复杂层。开发者们常常忽视这一点，因为这与他们在开发生产代码中所得出的经验不一致。

## 一些经典的 Bad Test

我经常看到一些非常优秀的开发者写出下面这样的测试

```python
def test_initial_score(self):
  initial_score = self.account_manager.get_score(username='joe123')
  self.assertEqual(150.0, initial_score)
```

这个测试做了什么？它查了用户`joe123`的`score`，并且检验它是否等于150。对于这个测试，你可能有下面的问题要问。

1. `joe123` 是从哪来的？
2. 为什么`joe123`的`score`要等于150？

问题的答案在`setUp`函数中，在测试框架执行测试之前，调用了`setUp`函数。

```python
def setUp(self):
  database = MockDatabase()
  database.add_row({
      'username': 'joe123',
      'score': 150.0
    })
  self.account_manager = AccountManager(database)
```

好的，`setUp`方法创建了一个分数为150的用户`joe123`，这解释了为什么`test_initial_score`期望这些值。现在，一切都很完美。可是事实真的是这样么？

答案是否定的，这是一个**Bad Test**。

## 让阅读测试代码的人只需要阅读测试代码

当你写测试的时候，要考虑遇到测试失败的开发者。他们不想阅读你的整个测试套件，更不想阅读一整套测试工具的继承树。

如果一个测试失败了，读者应该只需要从上到下阅读测试函数就能诊断出问题所在。如果他们还需要跳出测试函数去阅读辅助代码，那么这个测试就没有完成它的使命。

我们带着这个思路去重写这个测试。

```python
def test_initial_score(self):
  database = MockDatabase()
  database.add_row({
      'username': 'joe123',
      'score': 150.0
    })
  account_manager = AccountManager(database)

  initial_score = account_manager.get_score(username='joe123')

  self.assertEqual(150.0, initial_score)
```

我所做的就是将`setUp`方法中的代码内联到测试中，但这带来了巨大的改变。现在，读者需要的所有信息都直接呈现在测试中。它还遵循了[arrange, act, assert](http://wiki.c2.com/?ArrangeActAssert)结构，这使得测试的每个阶段都清晰明了。

{{<notice type="info">}}
**读者应该能够在不阅读其他代码的情况下理解你的测试。**
{{</notice>}}

## 敢于去违反"不要重复造轮子"原则

对于单个测试来说，内联设置代码是很好的，但如果我有很多测试呢？难道我每次都要重复这些代码吗？请做好心理准备，因为我即将要提倡[copy/paste programming](https://en.wikipedia.org/wiki/Copy_and_paste_programming)。

这是这个类的另外一个测试：

```python
def test_increase_score(self):
  database = MockDatabase()                  # <
  database.add_row({                         # <
      'username': 'joe123',                  # <--- Copy/pasted from
      'score': 150.0                         # <--- previous test
    })                                       # <
  account_manager = AccountManager(database) # <

  account_manager.adjust_score(username='joe123',
                         adjustment=25.0)

  self.assertEqual(175.0,
             account_manager.get_score(username='joe123'))
```

对于严格遵守[不要重复造轮子](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself)("don't repeat yourself")原则的人来说，上面的代码会让他们感到厌恶。我们竟然大张旗鼓地`repeat myself`；我从上面的测试用例中一字不差地复制了六行代码。更令人气愤的是，我竟然说我的违反"不要重复造轮子"原则的测试比遵守原则的测试更加优秀。这怎么可能呢？

如果你不需要使用重复的代码就可以让测试简明易懂，那是最好。但是请记住，不使用重复的代码是手段，而不是目的。我们的目的是让测试代码清晰、简单。

不要盲目地在测试代码中遵循"不要重复造轮子"原则。在编写测试时，你应该优先考虑如何让测试失败时的原因一目了然。虽然通过抽象和重构可以减少代码重复，但这种做法往往会增加排查问题的复杂度，并可能模糊掉关键信息。

{{<notice type="info">}}
**如果重复代码能让测试更容易理解，那就可以接受。**
{{</notice>}}

## 添加辅助函数的时候需要考虑一些别的

对于每个测试用例复制六行代码是轻松的，但是如果需要更多的`setUp`代码呢？

```python
def test_increase_score(self):
  # vvvvvvvvvvvvvvvvvvvvv Beginning of boilerplate code vvvvvvvvvvvvvvvvvvvvv
  user_database = MockDatabase()
  user_database.add_row({
      'username': 'joe123',
      'score': 150.0
    })
  privilege_database = MockDatabase()
  privilege_database.add_row({
      'privilege': 'upvote',
      'minimum_score': 200.0
    })
  privilege_manager = PrivilegeManager(privilege_database)
  url_downloader = UrlDownloader()
  account_manager = AccountManager(user_database,
                                   privilege_manager,
                                   url_downloader)
  # ^^^^^^^^^^^^^^^^^^^^^ End of boilerplate code ^^^^^^^^^^^^^^^^^^^^^^^^^^^

  account_manager.adjust_score(username='joe123',
                         adjustment=25.0)

  self.assertEqual(175.0,
             account_manager.get_score(username='joe123'))
```

这15行代码是去在测试开始之前去初始化`AccountManager`。到了这种程度，样板代码的堆积影响了你对测试行为本身的专注度。

你可能会本能地想把所有"无关紧要"的代码都抽象成辅助函数。但在这么做之前，我们应该先问问自己一个更重要的问题：为什么这个系统的测试如此困难？

大量的样板代码通常意味着系统架构存在问题。比如，上面的测试用例就暴露出了一些[design smells](https://en.wikipedia.org/wiki/Design_smell):

```python
account_manager = AccountManager(user_database,
                                 privilege_manager,
                                 url_downloader)
```

`AccountManager` 直接访问 `user_database`，但它的下一个参数是 `privilege_manager`，一个 `privilege_database` 的包装器。为什么它要在两个不同的抽象层次上操作呢？而且它为什么还需要一个`URL downloader`？这看起来与其他两个参数在概念上毫无联系。

{{<notice type="info">}}
**当你想要编写测试辅助函数时，不妨先尝试重构你的生产代码。**
{{</notice>}}

## 如果你需要辅助函数，请负责任地编写它们

有时候，我们没有修改系统架构的权限。这时，辅助函数是你唯一的选择。但是当你需要辅助函数的时候，把它们写好。

一个有效的辅助函数应该支持"让读者停留在你的测试函数中"的原则。只要不降低读者对测试的理解，将样板代码提取到辅助函数中是可以的。

具体来说，辅助函数**不应该**：

- 隐藏关键值
- 与被测对象进行交互

这里有一个违反这些准则的辅助函数示例：

```python
def add_dummy_account(self): # <- Helper method
  dummy_account = Account(username='joe123',
                          name='Joe Bloggs',
                          email='joe123@example.com',
                          score=150.0)
  # BAD: Helper method hides a call to the object under test
  self.account_manager.add_account(dummy_account)

def test_increase_score(self):
  self.account_manager = AccountManager()
  self.add_dummy_account()

  account_manager.adjust_score(username='joe123',
                               adjustment=25.0)

  self.assertEqual(175.0, # BAD: Relies on value set in helper method
                   account_manager.get_score(username='joe123'))
```

除非读者去查找隐藏在辅助函数中的150这个值，否则他们无法理解为什么最终分数应该是175。辅助函数也隐藏了`add_account`的行为。

下面是一个解决这些问题的重写版本：

```python
def make_dummy_account(self, username, score):
  return Account(username=username,
                 name='Dummy User',         # <- OK: Buries values but they're
                 email='dummy@example.com', # <-     irrelevant to the test
                 score=score)

def test_increase_score(self):
  account_manager = AccountManager()
  account_manager.add_account(
    make_dummy_account(
      username='joe123',  # <- GOOD: Relevant values stay
      score=150.0))       # <-       in the test

  account_manager.adjust_score(username='joe123',
                               adjustment=25.0)

  self.assertEqual(175.0,
                   account_manager.get_score(username='joe123'))
```

它仍然在辅助方法中隐藏了一些值，但这些值与测试无关。它还将`add_account`调用移回测试中，这样读者可以轻松地追踪`account_manager`中发生的所有事情。

{{<notice type="info">}}
**确保辅助方法中不包含读者理解测试所需的任何信息。**
{{</notice>}}

## 测试函数名尽量详细

你更愿意在生产代码中看到以下哪种函数名？

- `userExistsAndTheirAccountIsInGoodStandingWithAllBillsPaid`
- `isAccountActive`

第一个名字信息量更大，但长度达到了57个字符，使用起来有些繁琐。大多数开发者更愿意牺牲一点精确性，选择像 `isAccountActive` 这样简洁、几乎同样表达清楚意思的名字（除了 Java 开发者，他们觉得这两个名字都太短了😂）。

但对于测试函数，有一个关键因素改变了这个选择：你从来不会在代码中"调用"测试函数。开发者只需要在函数定义时写一次测试名。因此，虽然简洁依然重要，但在测试代码中，名字的长度远没有生产代码那么重要。

每当测试失败时，测试名是你首先看到的信息，所以它应该尽可能传达更多内容。例如，考虑下面这个生产类：

```c++
class Tokenizer {
 public:
  Tokenizer(std::unique_ptr<TextStream> stream);
  std::unique_ptr<Token> NextToken();
 private:
  std::unique_ptr<TextStream> stream_;
};
```

假设运行测试时出现了这样的输出：

```text
[  FAILED  ] TokenizerTests.TestNextToken (6 ms)
```

你能定位测试失败的原因么？我猜不能。

`TestNextToken` 失败只能告诉你 `NextToken()` 方法出了问题，但对于只有一个公共方法的类来说，这个信息毫无意义。要想定位失败的原因，你还得去读测试的具体实现。

但是如果你看到的输出是这样：

```text
[  FAILED  ] TokenizerTests.ReturnsNullptrWhenStreamIsEmpty (6 ms)
```

在其他场景下，像 `ReturnsNullptrWhenStreamIsEmpty` 这样的函数名可能显得过于冗长，但它却是一个很好的测试名。如果你看到这个测试失败，你会立刻知道这个类在处理空数据流时出现了问题。你甚至可能无需阅读测试的具体实现就能修复这个 bug。这正是好测试名的标志。

{{<notice type="info">}}
**给你的测试起一个足够好的名字，让别人仅凭名字就能判断出失败的原因。**
{{</notice>}}

## 拥抱魔法数字

"不要使用魔法数字。"

这句话就像编程世界里的"不要和陌生人说话"。许多有经验的开发者把这条教训牢记于心，以至于从未想过魔法数字有时其实能让代码更好。

简单回顾一下，"魔法数字"指的是在代码中出现的、没有说明其含义的数值或字符串。比如下面这个例子：

```python
calculate_pay(80) # <-- Magic number
```

程序员们同意在生产代码中使用魔法数字是一个`Very Bad Thing`，所以他们常常使用常量去替代魔法数字。

```python
HOURS_PER_WEEK = 40
WEEKS_PER_PAY_PERIOD = 2
calculate_pay(hours=HOURS_PER_WEEK * WEEKS_PER_PAY_PERIOD)
```

不幸的是，有一种误解认为魔法数字同样不适用于测试代码，但事实恰恰相反。

请看下面这个测试：

```python
def test_add_hours(self):
  TEST_STARTING_HOURS = 72.0
  TEST_HOURS_INCREASE = 8.0
  hours_tracker = BillableHoursTracker(initial_hours=TEST_STARTING_HOURS)
  hours_tracker.add_hours(TEST_HOURS_INCREASE)
  expected_billable_hours = TEST_STARTING_HOURS + TEST_HOURS_INCREASE
  self.assertEqual(expected_billable_hours, hours_tracker.billable_hours())
```

如果你认为魔法数字是绝对的"邪门歪道"，那么上面的测试对你来说看起来是正确的。`72.0` 和 `8.0` 都被赋予了有意义的常量名，因此没人会指责这个测试用了魔法数字。

但请暂时放下你对魔法数字的偏见，来尝试一下"禁果"吧：

```python
def test_add_hours(self):
  hours_tracker = BillableHoursTracker(initial_hours=72.0)
  hours_tracker.add_hours(8.0)
  self.assertEqual(80.0, hours_tracker.billable_hours())
```

明显更简单。它只使用了一般的代码，并且更加的直观 &mdash; 读者不需要为了弄清常量的真实值去在函数中跳转。

当我看到开发者在测试代码中定义常量时，通常是因为他们对"不要重复造轮子"（don't repeat youself）原则的误解，或者是害怕使用魔法数字。然而，测试中很少有必要去声明常量，这么做反而让测试变得更难理解。

{{<notice type="info">}}
**在测试代码中，优先使用魔法数字而不是命名常量。**
{{</notice>}}

{{<notice type="warning">}}
**单元测试可以引用生产代码中暴露的常量，但不应该在测试中自行定义常量。**
{{</notice>}}

## 总结

要编写优秀的测试，开发者必须让自己的工程决策(engineering decisions)与测试代码的目标保持一致。最重要的是，测试应当尽可能地简化，避免不必要的抽象。一个好的测试能够让读者在不离开测试函数的情况下，理解预期行为并定位问题。

---

_Cover art by Loraine Yow_
