class Calculator
  module Model
    class Command
      class Operation < Command
        class Subtract < Operation
          keywords '−', '-'
          
          def operation_method
            :-
          end
        end
      end
    end
  end
end
