# Generated by Django 3.2.4 on 2024-08-20 13:03

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('scanEngine', '0015_notification_send_visual_changes_to_slack'),
    ]

    operations = [
        migrations.AddField(
            model_name='notification',
            name='slack_channel_id',
            field=models.CharField(blank=True, max_length=12, null=True),
        ),
    ]
