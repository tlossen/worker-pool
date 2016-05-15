require "aws-sdk"

class Queue

  def initialize(name)
    @sqs = Aws::SQS::Client.new(
      region: "eu-central-1",
      credentials: Aws::Credentials.new(*open("credentials.csv").read.split(",").last(2))
    )
    @url = @sqs.create_queue(
      queue_name: name,
      attributes: {
        "VisibilityTimeout" => 10.to_s, 
      }
    ).queue_url
  end

  def send(body)
    @sqs.send_message(
      queue_url: @url, 
      message_body: body
    )
  end

  def receive
    @sqs.receive_message(
      queue_url: @url,
      max_number_of_messages: 1,
      wait_time_seconds: 10,
    ).messages.first
  end

  def delete(receipt_handle)
    @sqs.delete_message(
      queue_url: @url,
      receipt_handle: receipt_handle,
    )
  end
end







