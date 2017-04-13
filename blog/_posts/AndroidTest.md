---
title: Android Test
date: 2016-12-14 13:46:55
categories: Android
comments: true
---
## 分类

* **本地测试**
  * [JUnit4](http://junit.org/junit4/)
  * [Mockito](http://site.mockito.org/)

* **设备测试**
  * [Espresso](https://google.github.io/android-testing-support-library/docs/espresso/index.html)
  * [UI Automator](https://developer.android.com/training/testing/ui-testing/uiautomator-testing.html) `本文未提及`
  * [UI/Application Exerciser Monkey](https://developer.android.com/studio/test/monkey.html) `本文未提及`
  * [Monkeyrunner](https://developer.android.com/studio/test/monkeyrunner/index.html) `本文未提及`

## 测试框架
Android 测试采用的是 JUnit4 测试框架，不管本地测试还是设备测试 
### [JUnit4](http://junit.org/junit4/)
#### 常用注解类
* `@Test`：注解非静态公有方法，每个方法代表一个**测试用例**，可以设置超时时间，如 **@Test(timeout=500)** 表明该测试用例需要在 500ms 内执行完毕。还有如果我们想验证的是某个测试用例能否正确抛出指定异常的话可以这样（若没有抛出指定的异常反而会失败）：
```java
@Test(expected = IndexOutOfBoundsException.class) 
public void empty() { 
  //验证这种情况能否正确抛出指定异常，即下面这个测试用例因为抛出了指定异常所以它通过测试了
  new ArrayList<Object>().get(0);
  
  // 这一行不会执行，因为上面抛出异常了！！！
  System.out.println("Would not be executed");
}
```

* `@Before`：注解**非静态公有**方法，将会在每个测试用例执行**前**执行

* `@After`：注解**非静态公有**方法，将会在每个测试用例执行**后**执行

* `@Rule`：注解**非静态公有**对象或方法，该**对象**或**方法的返回值**必须是 TaskRule（推荐）或 MethodRule 的实现类。它相当于一个会伴随着测试用例的生命周期而创建、销毁的组件，省去我们自己在 `@Before` 和 `@After` 中管理该组件的生命周期，更加灵活。例如我们在**设备测试**中用到的 ActivityTestRule 会在测试开始前启动指定的 Activiy 并在测试结束后销毁该 Activity

* `@BeforeClass`：注解**静态公有**方法，在测试类初始化后，所有测试用例执行前执行

* `@AfterClass`：注解**静态公有**方法，在所有测试用例执行完成后，测试类被销毁前执行

* `@RunWith`：指定一个 JUnit Runner，该 Runner 会依次解析并执行测试用例。在**本地测试**中默认的 Runner 是 BlockJUnit4ClassRunner，而在**设备测试**中默认的 Runner 是 AndroidJUnitRunner。还有我们希望整合多个测试类的话就可以这样
```java
@RunWith(Suite.class)
@Suite.SuiteClasses({
    TestFeatureLogin.class,
    TestFeatureLogout.class,
    TestFeatureNavigate.class,
    TestFeatureUpdate.class
})
public class FeatureTestSuite {
    // the class remains empty,
    // used only as a holder for the above annotations
    // 当我们运行这个测试类的时候将会依次执行 @Suite.SuiteClasses 中添加的子测试类
}
```

* `@Ignore`：当我们在直接跑整个测试类时需要忽略某个测试用例的时候，可以在该方法上添加上该注解即可暂时忽略，同时我们可以注明忽略该用例的原因
```java
@Ignore("This test has not completed yet")
@Test
public void testSame() {
  assertThat(1, is(1));
}
```
<!-- more -->
#### 生命周期
![](https://okwmjvg92.qnssl.com/junit_lifecycle.png)
#### 断言 - [Assert](http://junit.org/junit4/javadoc/latest/index.html) 和 [Matcher](http://junit.org/junit4/javadoc/latest/org/hamcrest/CoreMatchers.html)
JUnit 依赖并扩展了 Hamcrest，我们可以使用十分丰富的断言以及匹配方法。例如
```java
@Test
public void testAssertEquals() {
  //第一参数表示断言失败的提示，后面俩参数就是需要断言的对象
  assertEquals("failure - strings are not equal", "text", "text");
}
```
还有其它有用的方法例如：assertArrayEquals、assertNotNull、assertFalse、assertSame 等等
这里就介绍到配合 assertThat 和 matcher 达到***语义化***断言的目标，例如
```java
//判断 responseString 是否包含 "color" 或者 "colour"
assertTrue(responseString.contains("color") || responseString.contains("colour"));
// equals to
assertThat(responseString, either(containsString("color")).or(containsString("colour")));

//判断 x 不等于 4
assertThat(x, is(not(4)));

//判断 myList 中包含有字符串 "3"
assertThat(myList, hasItem("3"));
```
### [Mockito](http://site.mockito.org/)
由于**本地测试**跑在电脑的本地 JVM 中，所以有些必须 Android 环境支持的组件没法正常工作，例如 Context、SharedPreferences 等等，这里我们就需要通过 Mockito 提供的方法 mock 出一个模拟对象，让它能在测试下触发模拟行为
#### Mock 一个对象有几种方法

1. 通过 mock 方法

```java
Context context = mock(Context.class) 
```
2. 将 MockitoJUnitRunner 指定为测试类的 Runner 然后用 `@Mock` 注解需要 mock 的对象的引用

```java
@RunWith(MockitoJUnitRunner.class)
public class TestClass{
    @Mock
    Context context;
}
```
3. 首先通过 `@Mock` 注解一个引用，然后可以再初始化方法中调用 MockitoAnnotations.initMocks 并传入该测试类的实例

```java
public class TestClass{
    @Mock
    Context context;

    @Before
    public void setup(){
        MockitoAnnotations.initMocks(this);
    }
}
```
4. 首先通过 `@Rule` 注解一个 MockitoJUnit.rule() 返回的对象，然后即可用 `@Mock` 注解指定对象引用了

```java
public class TestClass{
    @Rule
    public MockitoRule rule = MockitoJUnit.rule();

    @Mock
    public Context context;
}
```
#### 打桩

Mockito 提供了十分强大的打桩机制，例如
* 当调用 context 对象的 getString 方法并传入参数的 int 值为 R.string.test 时返回字符串 “TEST”

```java
Context context = mock(Context.class);
when(context.getString(R.string.test)).thenReturn("TEST");

// 通过
assertThat(context.getString(R.string.test),equalTo("TEST"))；
  
// 失败，因为并没有给参数 R.string.no_stub 打桩，默认返回 null
assertThat(context.getString(R.string.no_stub),equalTo("TEST"));

// 通过
assertThat(context.getString(R.string.no_stub),nullValue())；
```
* 设置 context 对象的 getString 方法只要参数是 int 值就返回指定字符串

```java
Context context = mock(Context.class);
when(context.getString(anyInt())).thenReturn("TEST");

// 通过
assertThat(context.getString(R.string.test),equalTo("TEST"))；
  
// 通过
assertThat(context.getString(R.string.no_stub),equalTo("TEST"));
```

* 可以通过 thenThrow 抛出异常

```java
@Test(expected = RuntimeException.class)
public void test() {
  LinkedList mockedList = mock(LinkedList.class);
  when(mockedList.get(0)).thenReturn("first");
  when(mockedList.get(1)).thenThrow(new RuntimeException());

  // 打印字符串 "first"
  System.out.println(mockedList.get(0));

  // 打印 null
  System.out.println(mockedList.get(999));
  
  // 抛出指定异常
  System.out.println(mockedList.get(1))；
}
```

* 当调用**空返回值**的方法时可以通过 doThrow 抛出异常

```java
doThrow(new RuntimeException()).when(mockedList).clear();

// 抛出指定异常
mockedList.clear();
```

* 自定义参数匹配器

```java
@Test(expected = IndexOutOfBoundsException.class)
public void test() {
    List mockedList = mock(LinkedList.class);

    final Matcher<Integer> matcher = new Matcher<Integer>() {
        @Override
        public boolean matches(Object item) {
            if(!(item instanceof Integer)){
                return false;
            }

            final Integer integer = (Integer) item;

            return integer >= 0 && integer <= 10;
        }

        @Override
        public void describeMismatch(Object item, Description mismatchDescription) {}

        @Override
        public void _dont_implement_Matcher___instead_extend_BaseMatcher_() {}

        @Override
        public void describeTo(Description description) {}
    };
	
  	// 当符合 matcher 条件是返回指定字符串
    when(mockedList.get(intThat(matcher))).thenReturn("Some Strings");
    // 当不符合 matcher 条件是抛出异常
    when(mockedList.get(
      intThat(not(matcher)))).thenThrow(newIndexOutOfBoundsException());

    mockedList.get(0);
    mockedList.get(10);
    mockedList.get(11);
}
```

> 注意：Mokito 提供了 argThat 方法的同时也提供了面向基本类型及其包装类的 booleanThat、intThat 等等，如果在判断基本类型的地方用了 argThat 会直接抛出  `NullPointerException` 异常（[版本：2.2.29](http://static.javadoc.io/org.mockito/mockito-core/2.2.28/org/mockito/ArgumentMatchers.html)），你可以将上面测试用例的 ingThat 改成 argThat 看看结果

* 对于多个参数的方法，如果其中一个参数用到了匹配器，其余的都需要换成匹配器方式

```java
// 失败，因为 someMethod 的前两个参数用到了匹配器而最后一个参数没用到
verify(mock).someMethod(anyInt(), anyString(), "third argument");

// 需要改成这样
verify(mock).someMethod(anyInt(), anyString(), eq("third argument"));
```

#### 行为验证

* 检验指定方法是否被调用过

```java
@Test
public void test(){
  Context context = mock(Context.class);
  when(context.getString(anyInt())).thenReturn("some strings");

  SomeOne someOne = new SomeOne(context);
  // someOne 的 getOnce 方法会调用 context.getString(R.string.some)
  someOne.getOnce();
  
  // 因为上文中 context 的 getString 方法被调用过一次，所以测试通过
  verify(context).getString(anyInt());
}
```

* 检验指定方法被调用的次数

```java
@Test
public void test(){
  Context context = mock(Context.class);
  when(context.getString(anyInt())).thenReturn("some strings");

  SomeOne someOne = new SomeOne(context);
  // getTwice 方法会调用 context.getString 方法两次
  someOne.getTwice();
  
  // 检验该方法是否只调用了一次？失败，
  verify(context,times(1)).getString(anyInt());
  // 等价于上面那位，失败
  verify(context).getString(anyInt());
  // 通过，确实调用了两次
  verify(context,times(2)).getString(anyInt());
}
```

还有 atLeastOnce、atLeast(int)、atMost(int) 以及 never 等方法

* 更强大检验方法

```java
@Test
public void test(){
  Context context = mock(Context.class);
  Context context2 = mock(Context.class);
  
  // 两次调用，传入不同参数
  context.getString(R.id.first);
  context.getString(R.id.second);
}
```
verifyNoMoreInteractions : 检验指定对象是否还有未被检验的调用
1. ```java
   vefiry(context).getString(R.id.first);
   // 因为上文只检验了 getString(R.id.first) 这个调用，还缺一个，所以失败
   verifyNoMoreInteractions(context);
   ```

2. ```java
   vefiry(context).getString(anyInt());
   // 因为 anyInt 直接匹配了上文中的两次调用，所以通过
   verifyNoMoreInteractions(context);
   ```

verifyZeroInteractions : 检验指定对象是否被调用过

1. ```
   // 因为 context 被调用了两次，所以失败
   verifyZeroInteractions(context);
   ```

2. ```java
   // 因为 context2 没有被调用过，所以通过
   verifyZeroInteractions(context2);
   ```

> 虽然这两个方法十分强大当官方建议我们不要滥用

* 检验方法的调用顺序

```java
@Test
public void test(){
  Context context = mock(Context.class);
  when(context.getString(anyInt())).thenReturn("some strings");

  SomeOne someOne = new SomeOne(context);
  
  someOne.getOnce();
  someOne.getTwice();

  InOrder inOrder = inOrder(someOne);

  // 通过，因为 someOne 的调用顺序确实是先调用了 getOnce 再调用 getTwice
  inOrder.verify(someOne).getOnce();
  inOrder.verify(someOne).getTwice();
}
```

> inOrder 方法可以同时传入多个对象，这样可以检验多个对象之间的调用顺序

#### 获取回调

 ArgumentCaptor，捕获某个对象的方法被传入的对象，例如该参数对象是个回调对象，就可以验证这个回调对象的的方法是否有某种行为，例如
```java
// 其中一种初始化方式，也可以通过注解 @Capture 初始化，类似 @Mock
ArgumentCaptor<Person> captor = ArgumentCaptor.forClass(Person.class);

// mock 的 start 方法会调用 mock2 的 someMethod 方法并传入一个 Person 对象（记为 p1，假设 p1.getName() = "John"），则
mock.start();
verify(mock2).someMethod(captor.capture());//这里 captor 会捕获到 p1
assertEquals("John",captor.getValue().getName());//测试通过
```
#### 最后

>更多信息请转官方文档 - [2.2.29](https://static.javadoc.io/org.mockito/mockito-core/2.2.29/org/mockito/Mockito.html#stubbing_with_exceptions)

### Espresso

如果需要在具体的设备上进行 UI 测试的话，就需要 Espresso 的帮助了。Espresso 主要有这几个部分组成：捕获 View、触发事件、检验行为。一个典型的 Espresso 测试用例是：

```java
onView(withId(R.id.my_view))      // withId(R.id.my_view) is a ViewMatcher
  .perform(click())               // click() is a ViewAction
  .check(matches(isDisplayed())); // matches(isDisplayed()) is a ViewAssertion
```

#### 开始之前

* 如果我们需要在指定的 Activity 中捕获相应的 View 的话首先就需要进入该 Activity，最简单的方法是:

```java
// 指定通过 Android 官方提供的 Runner 解析测试用例
@RunWith(AndroidJUnit4.class)
public class HelloWorldEspressoTest {

    @Rule // 会在测试用例执行前启动 MainActivity，在用例结束后销毁
    public ActivityTestRule<MainActivity> mActivityRule 
      = new ActivityTestRule(MainActivity.class);

    @Test
    public void listGoesOverTheFold() {
        onView(withText("Hello world!")).check(matches(isDisplayed()));
    }
}
```

* 有时 Activity 在启动前需要上层传入带数据的 Intent：

```java
@RunWith(AndroidJUnit4.class)
public class WebViewActivityTest {

    @Rule
    public ActivityTestRule mActivityRule =
        new ActivityTestRule(WebViewActivity.class,
            false /* Initial touch mode */, false /*  launch activity */) {
        @Override
        protected void afterActivityLaunched() {
            // Enable JavaScript.
            onWebView().forceJavascriptEnabled();
        }
    }

    @Test
    public void typeTextInInput_clickButton_SubmitsForm() {
      
      // Lazily launch the Activity with a custom start Intent per test
      mActivityRule.launchActivity(withWebFormIntent());
      
      //onWebView()
      //...
    }
}
```

#### [捕获 View - ViewMatchers](https://android.googlesource.com/platform/frameworks/testing/+/android-support-test/espresso/core/src/main/java/android/support/test/espresso/matcher/ViewMatchers.java)

* Espresso 提供了一系列的方法方便我们一步步地缩小范围，最终捕获到想要的 View

```java
// 在当前界面找到 id 为 editTextUserInput
onView(withId(R.id.editTextUserInput));

// 在当前界面找到字符串为 Sign-in 的 View
onView(withText("Sign-in"));

// 首先找到全部 id 为 button_signin 的 View,然后再确定唯一一个字符串为 Sign-in 的 View
onView(allOf(withId(R.id.button_signin), withText("Sign-in")));
```

* 对于 AdapterViews 如 ListView、GridView 等等来说，因为有缓存机制，未在界面显示出来的 item 可能甚至没添加到 View 层级中，只有滑动到该 item 的时候才加载，所以没法通过 onView 获取到

```java
// 在列表找到字符串为 Americano 的 item
onData(allOf(is(instanceOf(String.class)), is("Americano")));
```

* 由于 RecyclerView 比较特殊，官方提供了不同于 AdapterViews 的方式，需要引入 `espresso-contrib` 包的支持

```java
// 先找到该 Recyclerview 后再在 perform 方法中去确认具体的 item
onView(withId(R.id.recyclerView))
  .perform(RecyclerViewActions.actionOnItemAtPosition(ITEM_BELOW_THE_FOLD, click()));
```

* 更多：[WebView](https://google.github.io/android-testing-support-library/docs/espresso/web/index.html)、[List](https://google.github.io/android-testing-support-library/docs/espresso/lists/index.html)

#### [触发事件 - ViewActions](https://android.googlesource.com/platform/frameworks/testing/+/android-support-test/espresso/core/src/main/java/android/support/test/espresso/action/ViewActions.java)

```java
// 触发点击事件
onView(...).perform(click());

// 在输入框中输入字符串 Hello，然后退出输入法
onView(...).perform(typeText("Hello"), closeSoftKeyboard());

// 对于一个嵌在 ScrollView 中的子 View 来说，可以先自动滑到它再触发点击事件
onView(...).perform(scrollTo(), click());
```

> 注意：有些系统虽然在通过 typeText 时 传入的是 ”Hello“，即首字母有大写，但实际输入的是 ”hello“，所以如果要验证字符串的话会失败，因为首字母不匹配

#### 检验行为

* 最后我们如果想要检验某种行为的时候就需要在最后加上 check 方法，在方法里嵌入 matches 方法并传入 ViewMatchers 类提供的各种方法，这 ViewMatchers 就是我们在捕获 View 的时候用到的。

```java
// 检验 id 为 text_simple 的 TextView 显示的字符串时候为 Hello Espresso
onView(withId(R.id.text_simple)).check(matches(withText("Hello Espresso!")));

// 检验指定 View 是否已经显示
onView(allOf(withId(...), withText("Hello!"))).check(matches(isDisplayed()));
```

#### Intent 相关

需要引入 `espresso-intents` 包支持

* 打桩

```java
@Test
public void activityResult_IsHandledProperly() {
  // 创建一个 Intent 对象
  Intent resultData = new Intent();
  String phoneNumber = "123-345-6789";
  resultData.putExtra("phone", phoneNumber);
  
  // 当软件请求 "com.android.contacts" 页面的时候返回生成的 Intent
  ActivityResult result = new ActivityResult(Activity.RESULT_OK, resultData);
  intending(toPackage("com.android.contacts")).respondWith(result));
  
  // 当点击 pickButton 后正常会跳转到联系人页面，这里直接可以返回一个 mock 的 intent，然后显示
  // 出返回 Intent 中的手机号
  onView(withId(R.id.pickButton)).perform(click());

  // 通过
  onView(withId(R.id.phoneNumber).check(matches(withText(phoneNumber)));
}
```

* 检验

```java
@RunWith(AndroidJUnit4.class)
public class SimpleIntentTest {

  private static final String MESSAGE = "This is a test";
  private static final String PACKAGE_NAME = "com.example.myfirstapp";

  // IntentsTestRule 继承自 ActivityTestRule，方便测试 Intent 等
  @Rule
  public IntentsTestRule≶MainActivity> mIntentsRule =
    new IntentsTestRule≶>(MainActivity.class);

  @Test
  public void verifyMessageSentToMessageActivity() {

    // 输入一段字符串
    onView(withId(R.id.edit_message))
      .perform(typeText(MESSAGE), closeSoftKeyboard());

    // 这里点击后会跳转到 DisplayMessageActivity 并携带一些信息
    onView(withId(R.id.send_message)).perform(click());

    // 检验 DisplayMessageActivity 是否收到指定的信息
    intended(allOf(
      hasComponent(hasShortClassName(".DisplayMessageActivity")),
      toPackage(PACKAGE_NAME),
      hasExtra(MainActivity.EXTRA_MESSAGE, MESSAGE)));
  }
}
```

#### 异步支持

在我们设备的实际执行过程中，总会伴随着异步，例如请求网络之类的过程，但 Espresso 没法知道这一过程，所以碰到异步情况的时候因为数据没到位，View 没有正确显示，就会出现验证失败，测试不通过的情况。如果我们在异步的时候能让 Espresso 感知到并挂起，等异步结束后再继续执行即可解决。

1.**第一种方法**是官方提供支持的，需要引入 `espresso-idling-resource` 库
 * 首先需要继承 IdlingResource
```java
public class SimpleIdlingResource implements IdlingResource {

  @Nullable private volatile ResourceCallback mCallback;
  
  // 原子类，适应多线程情况
  private AtomicBoolean mIsIdleNow = new AtomicBoolean(true);

  @Override
  public String getName() {
    return this.getClass().getName();
  }

  @Override
  public boolean isIdleNow() {
    return mIsIdleNow.get();
  }

  // 在测试过程中，系统会调用这个方法并传入 callback 让我们持有
  @Override
  public void registerIdleTransitionCallback(ResourceCallback callback) {
    mCallback = callback;
  }

  // 当异步开启时候，设置为不可用即 false 让 Espresso 挂起；当异步执行完毕后设为 true 并回调持有的 
  // 的 callback 告知 Espresso 可以继续执行了
  public void setIdleState(boolean isIdleNow) {
    mIsIdleNow.set(isIdleNow);
    if (isIdleNow && mCallback != null) {
      mCallback.onTransitionToIdle();
    }
  }
}
```

 * 在**被**测试类中提供公有方法能让外部获取到上面的 IdlingResource
```java
public class MainActivity extends Activity{
  @Nullable
  private IdlingResource mIdlingResource;
  
  @NonNull
  public IdlingResource getIdlingResource() {
    if (mIdlingResource == null) {
      mIdlingResource = new SimpleIdlingResource();
    }
    return mIdlingResource;
  }
}
```
 * 在测试类中调用 getIdlingResource 方法获取 IdlingResource 实例并绑定该实例

```java
@RunWith(AndroidJUnit4.class)
public void test(){
  private IdlingResource mIdlingResource;

  @Before
  public void registerIdlingResource() {
    // 绑定
    mIdlingResource = mActivityRule.getActivity().getIdlingResource();
    Espresso.registerIdlingResources(mIdlingResource);
  }
  
  @After
  public void unregisterIdlingResource() {
    if (mIdlingResource != null) {
      // 解绑
      Espresso.unregisterIdlingResources(mIdlingResource);
    }
  }
}
```

 * 因为仅仅在**测试**时中调用这个 getIdlingResource 方法，即非测试情况下 mIdlingResource 保持 null 状态，避免不必要的实例化，所以需要在使用到 IdlingResource 的地方做好非空判断。例如我们模拟一个异步操作
```java
static void processMessage(final String message, final DelayerCallback callback,
                           @Nullable final SimpleIdlingResource idlingResource) {
  // 记得做非空判断，因为在非测试状态下应该是空的
  if (idlingResource != null) {
    idlingResource.setIdleState(false);
  }

  // 模拟一个异步行为
  Handler handler = new Handler();
  handler.postDelayed(new Runnable() {
    @Override
    public void run() {
      if (callback != null) {
        callback.onDone(message);
        // 异步结束，判断非空后回调 callback
        if (idlingResource != null) {
          idlingResource.setIdleState(true);
        }
      }
    }
  }, DELAY_MILLIS);
}
```

 * 这样，当软件调用 processMessage 模拟异步操作时，Espresso 即可挂起并等到它被我们持有的 callback 被回调。但通过上文我们可以看到 IdlingResource 的使用导致 测试代码和项目代码混在一起了，并不符合测试分离的思想，这是它最大的不足。

2.**第二种方法**是需要 RxJava 的支持，由于 Espresso 默认可以感知到 AsyncTask 的异步过程，也就是说当我们用 AsyncTask 执行异步操作的时候，Espresso 是会自动挂起直到异步结束的，但又由于 AsyncTask 并不好用，这里就体现出 RxJava 的灵活性了。

  在 RxJava 中我们一般会在 Schedulers.io() 返回的调度对象中执行异步操作，而该对象最终调用默认的线程池。所以如果我们能将它的默认线程池替换成 AsyncTask 的线程池，那么当我们项目中用 RxJava 在 Schedulers.io() 提供的 IO 线程中执行异步时 Espresso 就可以感知到了。具体替换过程：

```java
//需要在设置 io 之前 hook
RxJavaHooks.setOnIOScheduler(new Func1<Scheduler, Scheduler>() {
  @Override
  public Scheduler call(Scheduler scheduler) {
    return Schedulers.from(AsyncTask.THREAD_POOL_EXECUTOR);
  }
});
```

这样就无需像第一种方法中 IdlingResource 复杂的操作了

#### 最后

> 更多细节请看[官方教程](https://developer.android.com/training/testing/ui-testing/espresso-testing.html#setup)

## 引入

### 本地测试

* 地址：module-name/src/test/java/`packages`/...

* 依赖：
```groovy
dependencies {
  // JUnit4
  testCompile 'junit:junit:4.12'
  // 如果需要模拟 Android 框架需要引入 Mockito
  testCompile 'org.mockito:mockito-core:2.2.29'
}
```

### 设备测试

* 地址：module-name/src/androidTest/`pacekages`/...
* 依赖

```groovy
android {
  defaultConfig {
    // 所以下面要引入 Runner 支持库
    testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
  }
}

dependencies {
  // 引入 Runner 支持
  androidTestCompile 'com.android.support.test:runner:0.5'
  // 引入 JUnit4 Rules 支持
  androidTestCompile 'com.android.support.test:rules:0.5'
  // 这个库只包含了一些比较核心的操作
  androidTestCompile 'com.android.support.test.espresso:espresso-core:2.2.2'
  
  // 下面是可选的！！！
  // 添加对 IdlingResource 的支持，注意这个库需要使用 compile，而不仅仅是 androidTestCompile！！
  compile 'com.android.support.test.espresso:espresso-idling-resource:2.2.2'
  // 添加对 RecyclerView 测试的支持
  androidTestCompile 'com.android.support.test.espresso:espresso-contrib:2.2.2' 
  // 添加对 Intent 测试的支持
  androidTestCompile 'com.android.support.test.espresso:espresso-intents:2.2.2'
  // 添加对 WebView 测试的支持
  androidTestCompile 'com.android.support.test.espresso:espresso-web:2.2.2'
}
```

* **解决依赖冲突问题**：因为 runner、rules、espresso 等库默认依赖了 `com.android.support` 里面的众多库如 `appcompat-v7`、`support-annotations` 等等，同时由于他们更新并不同步，经常会出现依赖冲突或者重复依赖的问题，所以在做了上面操作后还需要添加

```java
dependencies {
  // ...
  // 篇幅原因，这里省略上面那些引入的依赖
  
  configurations{
    // 告知 Gradle 我们想忽略掉所有 androidTestCompile 引入 'com.android.support' 下的众多库们
    androidTestCompile.exclude group: 'com.android.support'
  }
  
  // 指定我们自己真正需要的版本
  compile 'com.android.support:appcompat-v7:' + rootProject.supportLibVersion
  compile 'com.android.support:support-annotations:' + rootProject.supportLibVersion
  // 如果上文引入了 espresso-contrib 的话还需要这个
  compile 'com.android.support:recyclerview-v7:' + rootProject.supportLibVersion
}
```

## 最后
如果发现遗漏希望能帮忙指正哈,
多谢阅读。
