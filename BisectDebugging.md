---
tags: [software-engineering]
---
# Bisect Debugging

I was using `git-bisect` a lot and asked myself if this approach was generally applicable. It turns out that it works surprisingly well in a lot of cases. And I keep getting reminded that it works through practice. That's why I'm writing this article.

But first, here are two triggers that show that I don't know what I'm doing:

* Randomly upgrade packages in the hope that it will fix a bug.
* Create bigger instance sizes in the hope that it will fix performance issues.

When I see myself doing these things, it's time to bust out bisect debugging.

## What is bisect debugging?

The idea is simple; apply the [Binary search alorithm](https://en.wikipedia.org/wiki/Binary_search_algorithm) to the debugging process. If you can map the search space into a flat line, then you are guaranteed to find a solution in `O(log n)` steps.

The first step is to map the search space. Find two bounds to the problem. On one side it's working, and on the other it's failing.

Cut the space in half, and test if the error occurs there. If it is, move the cursor to the half that's working, otherwise, move it to the half that's broken.

Repeat until you pin-point the problem.

That's the overall process.

Of course, reality is messy and doesn't always cleanly map to linear search space. And finding the exact half is not always measurable. But following that process has been immensely useful to me, over and over again.

## Why is it so good?

Mechanical; debugging is an uncertain process. Uncertainty is a big driver for procrastination. Especially as a young engineer, or when under time pressure, the uncertainty can become quite unbearable. Because bisect debugging is mechanical, I find that it helps reduce that uncertainty and focus on finding the root cause of the problem instead. It also helps to communicate to management or other teams what we tried and what the next steps are.

Knowledge; the process of mapping the search space in itself is useful. It helps expose the areas that I don't understand. In order to build the mental picture of the search space, I have to know what the space is like. Over time, this makes me a better engineer.

## How to map

.

## Times it doesn't work

Mapping is too hard.

The search space is not linearizable.

## Examples

TODO: Add some worked examples.

A good one is how to debug a networking connection issue.

## Bonus: weighted bisect debugging

With experience, it's possible to speed up the search process even further. If you know where the problem is more likely to be, split to that location instead of the half. Of course, even with experience, you might still be wrong.
