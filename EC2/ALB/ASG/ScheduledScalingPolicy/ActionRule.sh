
Question : 
So by default, I have set an autoscaling group for one of the different capacity of 1 and minimum to be 1 and max to be 4. And here, I have set a scheduled action to have a different 
capacity to be 3. It should be, it is a once, one-time action, has to perform at 7 p.m. today. So it is after 7 p.m. So it is my scheduled action, created two new instances and 
attached to the autoscaling group, and attached to the target group. So now my desired capacity is 3. And now, in fact, I could not even see my scaling action.”


What you’re observing is expected. After a one-time scheduled action runs, it doesn’t vanish—but it won’t show up in the future schedule list. 
Instead, it will remain in your Auto Scaling Group’s history. In other words, it’s not deleted, but it’s done its job and won’t run again. 
You’ll find its record in the activity history or the executed scaling actions log. 
Your new desired capacity is now in effect, and from here on, other scaling policies (if any) will handle future changes.

No, once the scheduled action runs and changes your desired capacity, it will not revert automatically. 
That new desired capacity stays in place until another scaling policy or manual action changes it. 
So, if you need capacity to drop later, you’d either schedule a separate scaling action or rely on your dynamic scaling policies.

Question :
“So it is like, once the scheduled action has got Vanished, if I put I required, then I have to create one more new scheduled action for future production.”

Exactly. Once that one-time scheduled action has run, if you want to change capacity again in the future—whether that’s reverting to a previous 
state or scaling differently—you’ll need to create a new scheduled action. Each scheduled action is independent, 
so you have to explicitly define any future scaling times or capacity adjustments.
