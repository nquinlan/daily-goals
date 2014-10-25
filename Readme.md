# Daily Goals
_Goals emailed daily._

This is a quick hack to email your goals to you every day. It uses [Google Drive](http://drive.google.com/), [Iron.io](http://iron.io), and [SendGrid](http://sendgrid.com).

It will send you a selection of goals from a Google Spreadsheet broken up into categories ([like so](https://docs.google.com/a/sendgrid.com/spreadsheet/ccc?key=0ArkKC73GgfRNdHd0X3U2b1J3SDFlMmtQWDZ2WEVqT3c)), by randomly picking a goal from each category.

## Getting Started

### Google Spreadsheet
This repository uses Google Drive as a datastore. You'll need to create a Google spreadsheet with your goals in it. The header row denotes the category of the goal, every subsequent cell in that column is a goal. 

![Google Spreadsheet Example](http://sendgrid.com/blog/wp-content/uploads/2013/12/Screen-Shot-2013-12-30-at-11.15.18-AM-e1388427728553.png)

### Uploading to Iron.io
To use this, you must have an Iron.io account. It's assumed you have a project already started. You'll also need to have the [IronWorker CLI](http://dev.iron.io/worker/reference/cli/) installed.

1. Clone the repository to your computer:
`git clone https://github.com/nquinlan/daily-goals.git daily-goals`
2. Move into the repository:
`cd daily-goals`
3. Download the `iron.json` file for your project, move this into your repository.
4. Upload the worker to Iron.io: `iron_worker upload DailyGoal`
5. Finally, schedule a task to run the uploaded code daily. Make sure to provide it with [a payload](https://github.com/nquinlan/daily-goals/blob/master/payload.sample.json), containing your Google Credentials, SendGrid Credentials, Google Drive Spreadsheet Key, and your email.



## Remember Your Goals
![EC2 Not Echinacea](http://d.pr/i/9SoE+)
