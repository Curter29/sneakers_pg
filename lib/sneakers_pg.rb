module Sneakers
  module Worker
    def do_work(delivery_info, metadata, msg, handler)
        super(delivery_info, metadata, msg, handler)
      rescue PG::ConnectionBad, PG::UnableToSend => e
        logger.error(e)
        # Подождать какое то время, чтобы не плодить битые воркеры пока переключается haproxy
        sleep 2
        # Убиваем этот процесс, мастер процесс породит новый уже с нормальным соединением
        Process.kill('TERM', Process.pid)
    end
  end
end
