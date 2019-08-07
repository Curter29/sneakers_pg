# старый подход решения
# Подождать какое то время, чтобы не плодить битые воркеры пока переключается haproxy
# sleep 2
# Убиваем этот процесс, мастер процесс породит новый уже с нормальным соединением
# Process.kill('TERM', Process.pid)

module Sneakers
  module Worker
    def do_work(delivery_info, metadata, msg, handler)
      # https://github.com/jondot/sneakers/blob/master/lib/sneakers/worker.rb#L46
      worker_trace "Working off: #{msg.inspect}"

      # пул потоков - нужно ловить ex внутри потока!
      @pool.post do
        begin
          process_work(delivery_info, metadata, msg, handler)
        rescue PG::ConnectionBad, PG::UnableToSend => e
          sleep 2

          ActiveRecord::Base.connection.reconnect!
          Sneakers::CONFIG[:hooks][:after_pg_broken].call if Sneakers::CONFIG[:hooks][:after_pg_broken]

          logger.error(e)

          retry
        end
      end
    end
  end
end
