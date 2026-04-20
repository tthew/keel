---
title: The shipping gap
date: 2026-03-23
excerpt: On why I keep starting SaaS projects and then not finishing them, and the slowly dawning realisation that it isn't one problem but five, and they stack.
---

I've got a folder on my laptop called `projects/` and I'd rather you didn't look in it.

Inside are maybe fifteen directories with names like `thing-v2`, `another-thing`, `definitely-this-time`. Each one got between three and thirty days of my attention. Most have a working landing page, a signup flow, and an admin dashboard I never actually used. None of them have paying customers. Very few are even live.

For a while I told myself this was just discipline, or motivation, or the usual indie-hacker excuse of "I got bored". Those are partly true. But if I'm being honest, something else is going on. Every time I start a project I end up paying the same small taxes, five times in a row, and by the time I've finished paying them I've spent a week and lost the thread.

## The five little taxes

**The auth tax.** Every project needs a login, because the thing I'm actually building only starts to matter once someone's signed in. Auth isn't hard, exactly, but it has a lot of corners: email verification, password reset, OAuth buttons, session storage, step-up for sensitive actions. Every time I do it I remember that this is not something I find interesting.

**The infra tax.** Postgres somewhere, a queue somewhere else, a cron runner, a log collector, environment variables that never quite line up between dev and prod. I know how to set all of this up. I don't want to set all of this up. Again.

**The context tax.** I paired with Claude Code on my last project and I liked it, but every time I start a new session it asks me roughly the same questions about my stack. Postgres or MySQL? Stripe or Paddle? Where does the ORM live? The model doesn't remember what I told it yesterday. I don't always remember what I told it yesterday either.

**The scope tax.** Somewhere around day four I talk myself into building an admin UI I don't need, and a webhook system I'll never subscribe to, and a rate limiter to handle the traffic I'm definitely going to get. I know I should cut this. I cut it four projects ago. I cut it three projects ago. Funnily enough, it keeps coming back.

**The decision tax.** The one underneath all the others. Which billing provider? Which auth library? Do I bother with feature flags? Where do the translations live? These are questions I've answered before, usually more than once, and the answers don't really change. But a blank repo makes you answer them again.

## Any one of these is fine

This is the bit that kept tripping me up. Any one of these taxes, on its own, is survivable. I can burn a day on auth. I can spend an afternoon deciding where the queue goes. I can handle Claude asking me the same question three times in one session if I'm getting value from the session.

What's not survivable is all five, back to back, at the start of every new project, before I've even written a line of the thing I actually want to build. That's where the energy goes. It's not a line of code. It's not a bad tool. It's a cumulative drag that gets me to roughly day seven of a new project, where I look at what I've got, remember I still haven't built the interesting part, and quietly tab over to something else.

## So what do I do about it

Turns out I've been wrong about what the answer looks like. For years I thought the answer was a boilerplate, because boilerplate was what was on offer, and boilerplate _does_ help with the auth tax and the infra tax. Two out of five isn't bad, I told myself, and bought another one.

Two out of five is, in fact, bad. The taxes I wasn't paying were the ones I felt the most.

I've been poking at what the actual answer might be for a few months now, and it's something different from a boilerplate. More on that in the next post.
