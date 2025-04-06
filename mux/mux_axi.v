module old_mux (
    /* для каждого источника свой data, valid, last ready,
    при поступлении сигнала ready - передаем данные
    при поступлении сигнала last - на этом такте будет последний пакет данных и переходим к следующему
    источнику
    реализовать 4 источника
    source - отдельные модули
    sink - генерирует ready
    как только ready уходит - все источники должны прекратить передачу данных и замереть
    интерфейсы - подключать как структуру
    valid - формирует source
    4 на вход - он в них slave
    sink - может просто формировать ready
    */
    input clk,
    input [1:0] valid,
    input [1:0] last,
    input rst_n,
    input [15:0] data,
    //input [1:0] ready,
    output reg valid_out,
    output reg last_out,
    output reg [7:0] data_out,
    input ready_out,
    output reg [1:0] ready_in

);
    reg [1:0] select;

    always @(posedge clk) begin

        if (!rst_n) begin
            valid_out  <= 0;
            last_out <= 0;
            data_out <= 0;
            ready_in <= 0;
            select <= 0;
        end else begin
            if (ready_out) begin
                ready_in <= 2'b01;
                // Нужно ли добавлять тут ready_in?
                valid_out <= valid[select];
                last_out <= last[select];
                if (select == 1'b0) begin
                    data_out <= data[7:0];
                end else begin
                    data_out <= data[15:8];
                end
                
                //ready_in <= (valid[select] && ready_out) ? (1 << select) : 0;

                // Если получен сигнал tlast, переключаемся на следующий источник
                if (last[select] && valid[select]) begin
                    select <= (select == 1) ? 0 : select + 1;
                end else begin
                    ready_in <= 0;
                end
            end
        end
    end




endmodule;
