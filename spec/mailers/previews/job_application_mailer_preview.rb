class JobApplicationMailerPreview < ActionMailer::Preview
  def success
    job_application = JobApplication.last

    JobApplicationMailer.with(job_application: job_application).success
  end
end
