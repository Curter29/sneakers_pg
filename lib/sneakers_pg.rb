module Sneakers
  module Worker
    def do_work(delivery_info, metadata, msg, handler)
        __initial_reconnect ||= ActiveRecord::Base.connection.reconnect! && :done

        # https://github.com/jondot/sneakers/blob/master/lib/sneakers/worker.rb#L46
        worker_trace "Working off: #{msg.inspect}"

        @pool.post do
          process_work(delivery_info, metadata, msg, handler)
        end
      rescue PG::ConnectionBad, PG::UnableToSend => e
        sleep 2

        ActiveRecord::Base.connection.reconnect!
        Sneakers::CONFIG[:hooks][:after_pg_broken].call if Sneakers::CONFIG[:hooks][:after_pg_broken]

        work_rescue(e)
        logger.error(e)

        retry

        # старый подход решения
        # Подождать какое то время, чтобы не плодить битые воркеры пока переключается haproxy
        # sleep 2
        # Убиваем этот процесс, мастер процесс породит новый уже с нормальным соединением
        # Process.kill('TERM', Process.pid)
    end

    def work_rescue(e)
    end
  end
end
