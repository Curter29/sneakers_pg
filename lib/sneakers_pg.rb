module Sneakers
  module Worker
    def do_work(delivery_info, metadata, msg, handler)
        __initial_reconnect ||= ActiveRecord::Base.connection.reconnect! && :done

        super(delivery_info, metadata, msg, handler)
      rescue PG::ConnectionBad, PG::UnableToSend => e
        sleep 2
        ActiveRecord::Base.connection.reconnect!

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
