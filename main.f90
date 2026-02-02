program happy_numbers
    use omp_lib
    implicit none
    
    integer :: bound, happy_count, i, num_args
    real(8) :: percentage
    character(len=100) :: arg
    integer :: ios
    
    ! Get command line arguments
    num_args = command_argument_count()
    
    if (num_args /= 1) then
        call get_command_argument(0, arg)
        write(0, '(A,A)') 'Usage: ', trim(arg), ' BOUND'
        write(0, '(A)') '  BOUND: positive integer to check happy numbers from 1 to BOUND'
        stop 1
    end if
    
    ! Parse BOUND argument
    call get_command_argument(1, arg)
    read(arg, *, iostat=ios) bound
    
    if (ios /= 0) then
        write(0, '(A)') 'Error: BOUND must be a valid integer'
        stop 1
    end if
    
    if (bound < 1) then
        write(0, '(A)') 'Error: BOUND must be a positive integer (greater than 0)'
        stop 1
    end if
    
    ! Calculate happy numbers in parallel
    happy_count = 0
    
    !$omp parallel do reduction(+:happy_count) schedule(dynamic)
    do i = 1, bound
        if (is_happy(i)) then
            happy_count = happy_count + 1
        end if
    end do
    !$omp end parallel do
    
    ! Calculate and print percentage
    percentage = (real(happy_count, 8) / real(bound, 8)) * 100.0d0
    write(*, '(A,I0,A,I0,A,F0.2,A)') 'Happy numbers from 1 to ', bound, ': ', &
                                      happy_count, ' (', percentage, '%)'
    
contains

    ! Calculate sum of squares of digits
    function sum_of_squares(n) result(sum)
        integer, intent(in) :: n
        integer :: sum, temp, digit
        
        sum = 0
        temp = n
        
        do while (temp > 0)
            digit = mod(temp, 10)
            sum = sum + digit * digit
            temp = temp / 10
        end do
    end function sum_of_squares
    
    ! Check if a number is happy
    function is_happy(n) result(happy)
        integer, intent(in) :: n
        logical :: happy
        integer :: current, j
        integer, dimension(1000) :: seen
        integer :: seen_count
        logical :: found
        
        current = n
        seen_count = 0
        happy = .false.
        
        do while (current /= 1)
            ! Check if we've seen this number before (cycle detection)
            found = .false.
            do j = 1, seen_count
                if (seen(j) == current) then
                    found = .true.
                    exit
                end if
            end do
            
            if (found) then
                return  ! Cycle detected, not happy
            end if
            
            ! Add current number to seen list
            if (seen_count < 1000) then
                seen_count = seen_count + 1
                seen(seen_count) = current
            else
                return  ! Too many iterations, assume not happy
            end if
            
            current = sum_of_squares(current)
        end do
        
        happy = .true.
    end function is_happy

end program happy_numbers
